require 'redis'
require 'uri'

module Crocoduck
  uri = URI.parse "http://localhost:6379"
  Redis = ::Redis.new({ :host => uri.host, :port => uri.port, :password => uri.password })
end
