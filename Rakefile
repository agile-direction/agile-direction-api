require File.expand_path("../config/application", __FILE__)

if %w(development test).include?(Rails.env)
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ["--display-cop-names", "--fail-fast"]
  end

  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:rspec)

  require "cucumber/rake/task"
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end

  task(:audit_dependencies) do
    system("bin/bundle-audit") || exit
  end

  task({ test: %w(rspec teaspoon features rubocop audit_dependencies) })
end

Rails.application.load_tasks
