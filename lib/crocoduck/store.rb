# The Crocoduck::Store object handles the concern of talking to your
# data storage layer.  By default, we have implemented this on top
# of MongoDB, so it may be that many of the choices made here highly
# favor document-based databases.
require 'mongo'
require 'crocoduck/logging'

module Crocoduck
  class Store
    include Logging
    # We have several class properties that defined how all Store
    # objects will connect and query for information.  As stated
    # before, many of these will only make sense for MongoDB or
    # other similar document-based databases.
    @id_field = '_id'
    @server_cluster = nil
    @server_db = nil
    @server_collection = nil

    class << self
      attr_accessor :id_field, :server_cluster, :server_db, :server_collection
    end
    
    attr_accessor :store, :database, :collection
    
    # A nice method to determine if there is enough information
    # to potentially connect to the backing database.
    def setup?
      Crocoduck::Store.server_cluster && 
      Crocoduck::Store.server_db && 
      Crocoduck::Store.server_collection
    end

    def close
      store.close
    end

    # A simple convienance method to update a single
    # document in your datastore.
    def update(entry_id, field, value)
      collection.update({
        Crocoduck::Store.id_field => entry_id}, 
        {'$set' => { field => value}
      }, :safe => true)
    end
    
    # Returns a single document given its ID
    def get(id)
      collection.find_one({
        Crocoduck::Store.id_field => id.to_i
      })
    end
    
    # Use this method to remove documents from your datastore.  Cares
    # has been taken to prevent accidental database destruction.  Only
    # pass {} to this method if you are 100% sure you want to clear the
    # database.
    def remove(criteria=nil)
      return if criteria.nil?
      collection.remove criteria
    end
    
    # Inserts a brand new document into the database
    def insert(document)
      collection.insert document
    end
    
    private
    
    # These methods create and cache objects that maintain the state and
    # connectivity to the backend storage.
    def collection
      @collection ||= database.collection Crocoduck::Store.server_collection
    end
    
    def database
      @database ||= store.db(Crocoduck::Store.server_db)
    end
    
    def store
      @store ||= Mongo::ReplSetConnection.new(*Crocoduck::Store.server_cluster)
    end
  end
end