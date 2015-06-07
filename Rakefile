# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Build UI and copy to public folder'
task :import_ui do
  `cd ../agile-direction-ui &&
    ember build --environment=production &&
    cd ../agile-direction-api &&
    cp ../agile-direction-ui/dist/assets/{agile-direction-ui,vendor}* public/assets/ &&
    cp ../agile-direction-ui/dist/index.html app/views/application/index.html.erb
  `
end
