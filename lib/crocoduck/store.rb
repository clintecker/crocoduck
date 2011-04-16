require 'mongo'
require 'crocoduck/logging'

module Crocoduck
  class Store
    include Logging
    
    attr_accessor :store, :entries
    def initialize(mongo_cluster, db_name)
      @mongo = Mongo::Connection.multi(mongo_cluster).db(db_name)
    end
    
    def entries
      @entries ||= store.collection('entries')
    end
    
    def put(entry_id, data)
    end
    
    def get(entry_id)
      entries.find_one({'_id' => entry_id.to_i})
    end
    
    def close
      store.close
    end
  end
end