$:.unshift File.expand_path('../lib', __FILE__)
require 'resque/tasks'

task :default => :test

namespace :resque do
  task :setup do
    environment = ENV['CROCODUCK_ENV'] || 'development'
    require "config/#{environment}"
  end
end

desc "build the docco documentation"
task :docs do
  system 'docco ./lib/crocoduck/*.rb'
  system 'echo "<!DOCTYPE html><html lang=\"en\"><head><title>Crocoduck: A specialized Resque Job System</title></head><body>`rdiscount README.md`</body></html>" > index.html'
end

require 'rake/testtask'
Rake::TestTask.new
