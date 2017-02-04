gem_group :development, :test do
  gem "pry-coolline"
  gem "pry-rails"
  gem "pry-doc"
  gem "pry-byebug"
  gem "pry-stack_explorer"

  gem "better_errors"
  gem "binding_of_caller"
  gem "rails-flog", require: "flog" # Log formatter for SQL and hash

  gem "guard-livereload", require: false
  gem "guard-rspec", require: false

  gem "awesome_print"
  gem "hirb"
  gem "hirb-unicode"

  gem "spring-commands-rspec"
end

gem_group :test do
  gem "database_cleaner"
  gem "rspec-rails"
  gem "rspec-its"
  gem "factory_girl_rails", require: false
  gem "capybara"
  gem "capybara-screenshot"
  gem "poltergeist"
  gem "simplecov"
end
