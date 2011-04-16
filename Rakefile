require 'rubygems'
gem 'rspec', '1.2.9'
require 'bundler'
require 'spec/rake/spectask'
require 'rake/testtask'
require 'mongo'

task :default => [:test, :spec]

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

Rake::TestTask.new

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  t.spec_opts << '--format specdoc'
end
