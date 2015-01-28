require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.profile = 'ci'
end

Cucumber::Rake::Task.new(:features_pretty) do |t|
  t.profile = 'ci-pretty'
end

task :default => :features