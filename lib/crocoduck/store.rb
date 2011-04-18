require 'mongo'
require 'crocoduck/logging'

module Crocoduck
  class Store
    include Logging
    @id_field = '_id'
    @server_cluster = nil
    @server_db = nil
    @server_collection = nil

    class << self
      attr_accessor :id_field, :server_cluster, :server_db, :server_collection
    end
    
    attr_accessor :store, :database, :collection

    def setup?
      Crocoduck::Store.server_cluster && 
      Crocoduck::Store.server_db && 
      Crocoduck::Store.server_collection
    end

    def collection
      @collection ||= database.collection Crocoduck::Store.server_collection
    end
    
    def update(entry_id, field, value)
      collection.update({
        Crocoduck::Store.id_field => entry_id}, 
        {'$set' => { field => value}
      }, :safe => true)
    end
        
    def get(id)
      collection.find_one({
        Crocoduck::Store.id_field => id.to_i
      })
    end
    
    def close
      store.close
    end
    
    private
    
    def database
      @database ||= store.db(Crocoduck::Store.server_db)
    end
    
    def store
      @store ||= Mongo::ReplSetConnection.new(*Crocoduck::Store.server_cluster)
    end
  end
end