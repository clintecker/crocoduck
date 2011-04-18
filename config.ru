$:.unshift File.expand_path('../lib', __FILE__)

require 'crocoduck/server'

environment = ENV['CROCODUCK_ENV'] || 'development'
require "config/#{environment}"

run Crocoduck::Server