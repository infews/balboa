require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: [:standard, :spec]

desc "Run Standard Ruby with --fix"
task :standard do
  `bundle exec standardrb --fix`
end
