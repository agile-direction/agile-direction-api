ruby("2.2.2")
source("https://rubygems.org")

gem("haml")
gem("haml-rails")
gem("jbuilder", "~> 2.0")
gem("pg")
gem("rack-cors")
gem("rails", "4.2.1")

group(:production) do
  gem("puma")
end

group(:doc) do
  gem("sdoc", "~> 0.4.0")
end

group(:development) do
  gem("foreman")
end

group(:development, :test) do
  gem("byebug")
  gem("dotenv")
  gem("rspec-rails", "~> 3.0")
  gem("shotgun")
  gem("spring")
  gem("web-console", "~> 2.0")
  gem("guard")
  gem("guard-rails", { require: false })
  gem("guard-rspec", { require: false })
end

group(:test) do
  gem("bundler-audit")
  gem("cucumber-rails", { require: false })
  gem("database_cleaner")
  gem("faker")
  gem("launchy")
  gem("poltergeist")
  gem("rubocop", { require: false })
  gem("selenium-webdriver")
end
