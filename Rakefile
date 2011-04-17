$:.unshift File.expand_path('../lib', __FILE__)
require 'mongo'
require 'resque/tasks'


namespace :db do
  desc "Create indexes"

  namespace :index do
    task :production do
      mongo = Mongo::Connection.multi([['10.10.10.2', 27017], ['10.10.10.10', 27017], ['10.10.10.9', 27017]]).db('ars')
      mongo.collection('entries').create_index('shorturl.status.success')
    end

    task :development do
      mongo = Mongo::Connection.new.db('ars_api_development')
      mongo.collection('entries').create_index('shorturl.status.success')
    end
  end
end

task :default => :test

require 'rake/testtask'
Rake::TestTask.new
