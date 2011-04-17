require 'crocoduck/redis'
require 'resque'
require 'resque/server'

module Crocoduck
  Resque = ::Resque
  ::Resque.redis = Redis
end
