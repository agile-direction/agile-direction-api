require 'cucumber/rails'
require 'capybara/poltergeist'

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {debug: false})
end
Capybara.default_driver = Capybara.javascript_driver = :poltergeist

# seed
CSVImport.import!('db/seeds/test_data.csv')
