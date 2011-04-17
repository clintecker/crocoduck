require 'redis'
require 'uri'

module Crocoduck
  uri = URI.parse ENV['REDIS_URL']
  Redis = ::Redis.new host: uri.host, port: uri.port, password: uri.password
end
