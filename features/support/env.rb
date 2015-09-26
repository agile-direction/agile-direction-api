ENV["RACK_ENV"] = ENV["RAILS_ENV"] = "test"

require "capybara/poltergeist"
require "cucumber/rails"
require "faker"
require "spec/helpers/generator"
require Rails.root.join("lib/builders")

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :truncation
Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.app = Builders::FULL_STACK

headless = (ENV["HEADLESS"] == "true")
if headless
  Capybara.register_driver(:poltergeist) do |app|
    driver = Capybara::Poltergeist::Driver.new(app, {
      debug: false,
      extensions: ["vendor/poltergeist/bind.js"],
      js_errors: false
    })

    def driver.accept_modal(*_args)
      yield if block_given?
    end

    driver
  end
else
  Capybara.register_driver(:browser) do |app|
    Capybara::Selenium::Driver.new(app, { browser: :chrome })
  end
end
Capybara.default_driver = Capybara.javascript_driver = (headless ? :poltergeist : :browser)

CSVImport.import!("db/seeds/test_data.csv")
