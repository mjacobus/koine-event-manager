require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
end

namespace :test do
  task :coveralls do
    ENV["COVERALLS"] = "true"
    Rake::Task["test:coverage"].invoke
  end

  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task["test"].invoke
  end

  task :scrutinizer do
    ENV["SCRUTINIZER"] = "true"
    Rake::Task["test"].invoke
  end
end

task :default => :test
