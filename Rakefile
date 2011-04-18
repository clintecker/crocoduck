$:.unshift File.expand_path('../lib', __FILE__)
require 'mongo'
require 'resque/tasks'
require 'crocoduck/job'

task :default => :test

namespace :resque do
  task :setup do
    environment = ENV['CROCODUCK_ENV'] || 'development'
    require "config/#{environment}"
  end
end

require 'rake/testtask'
Rake::TestTask.new
