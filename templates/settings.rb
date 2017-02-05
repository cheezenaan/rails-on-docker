# config/application.rb
# refs. https://railsguides.jp/generators.html#application
application do
  <<-"EOS"
config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framekwork :rspec,
        fixture: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
EOS
end

# locale files
remove_file "config/locales/en.yml"
get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml", "config/locales/en.yml"
get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml", "config/locales/ja.yml"

# better_errors
# refs. https://github.com/charliesome/better_errors#security
environment 'BetterErrors::Middleware.allow_ip! "0.0.0.0/0"', env: :development

# Rspec
generate "rspec:install"
run "rm -rf test"
uncomment_lines "spec/rails_helper.rb", /Dir\[Rails\.root\.join/

# capybara, factory_girl
insert_into_file "spec/rails_helper.rb", <<RUBY, after: "RSpec.configure do |config|\n",
  config.include Capybara::DSL
RUBY

insert_into_file "spec/spec_helper.rb", <<RUBY, before: "RSpec.configure do |config|"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "capybara/poltergeist"
require "factory_girl_rails"
require "simplecov"

Capybara.server_host = "localhost"
Capybara.server_port = 3001
Capybara.javascript_driver = "poltergeist"
RUBY

# simplecov
insert_into_file "spec/spec_helper.rb", <<RUBY, before: "RSpec.configure do |config|"
SimpleCov.start "rails" do
  add_filter "/vendor/"
  add_filter "/spec/"
end
RUBY

# database_cleaner
# refs. http://ruby-rails.hatenadiary.com/entry/20150204/1423055537#first-settings-test
gsub_file "spec/rails_helper.rb", "config.use_transactional_fixtures = true", "config.use_transactional_fixtures = false"
insert_into_file "spec/rails_helper.rb", <<RUBY, before: "RSpec.configure do |config|"
require "database_cleaner"
RUBY

insert_into_file "spec/rails_helper.rb", <<RUBY, after: "RSpec.configure do |config|\n"
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
RUBY

# .pryrc(to use awesome_print, hirb)
# refs. http://qiita.com/necojackarc/items/9cd4ce16323111021caa
create_file ".pryrc", <<RUBY
# awesome_print
begin
  require "awesome_print"
  Pry.config.print = proc { |output, value| output.puts value.ai }
rescue LoadError
  puts "Awesome Print is currently not installed yet ..."
end

# hirb
begin
  require "hirb"
rescue LoadError
  puts "Hirb is currently not installed yet ..."
end

if defined? Hirb
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end
RUBY

# guard-rspec
# refs. http://ruby-rails.hatenadiary.com/entry/20141021/1413819783
run "bundle e guard init rspec"

# spring
# refs. http://ruby-rails.hatenadiary.com/entry/20141026/1414289421
run "bin/spring stop"
run "bundle e spring binstub rspec"

# [WIP] Remove unused files
remove_file "README.rdoc"

# stylesheets
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"

# config/database.yml
remove_file "config/database.yml"
create_file "config/database.yml", '
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: <%= ENV["MYSQL_USERNAME"] %>
  password: <%= ENV["MYSQL_PASSWORD"] %>
  host: <%= ENV["MYSQL_HOST"] %>

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test
'

# database migration
rake "db:create"
rake "db:migrate"

# [TODO] .gitignore

# [WIP] Remove unneccesary lines
empty_line_pattern = /^\s*\n/
comment_line_patttern = /^\s*#.*\n/

gsub_file "Gemfile", comment_line_patttern, ""

gsub_file "config/routes.rb", comment_line_patttern, ""
gsub_file "config/routes.rb", empty_line_pattern, ""

gsub_file "config/database.yml", empty_line_pattern, ""

# gsub_file "config/environments/production.rb", comment_line_patttern, ""
gsub_file "config/environments/development.rb", comment_line_patttern, ""
# gsub_file "config/environments/test.rb", comment_line_patttern, ""

# gsub_file "config/initializers/assets.rb", comment_line_patttern, ""
# gsub_file "config/initializers/assets.rb", empty_line_pattern, ""

# gsub_file "spec/rails_helper.rb", comment_line_patttern, ""
# gsub_file "spec/spec_helper.rb", comment_line_patttern, ""

# gsub_file "config/application.rb", comment_line_patttern, ""
