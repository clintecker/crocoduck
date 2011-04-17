require 'mongo'
require 'crocoduck/logging'

module Crocoduck
  class Store
    include Logging
    @id_field = '_id'
    
    attr_accessor :store, :entries, :collection, :db_name, :mongo_cluster
    def initialize(mongo_cluster, db_name1, collection)
      @collection = collection
      @db_name = db_name
      @mongo_cluster = mongo_cluster
    end
    
    def entries
      @entries ||= store.collection collection
    end
    
    def update(entry, field, value)
      entries.update({id_field => entry[id_field]}, {'$set' => { field => value}}, :safe => true)
    end
        
    def get(entry_id)
      entries.find_one({id_field => entry_id.to_i})
    end
    
    def close
      store.close
    end
    
    private
    
    def store
      @store ||= Mongo::Connection.multi(mongo_cluster).db(db_name)
    end
  end
end