require 'json'
require 'crocoduck/job'
require 'crocoduck/redis'
require 'crocoduck/resque'
require 'crocoduck/store'

module Crocoduck
  class Entry
    def self.keys
      Redis.keys "entries:*"
    end
    
    def self.find(entry_id)
      if json = Redis.get("entries:#{entry_id}")
        new JSON.parse(json)
      end
    end
    
    attr_accessor :entry_id, :entry, :store_cluster, 
                  :store_db_name, :store_collection,

    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send "#{key}=", value
      end
    end
    
    def save
      Redis.set "entries:#{entry_id}", to_json
    end
    
    def schedule(worker)
      worker ||= Job
      Resque.enqueue worker, entry_id
    end
    
    def entry
      @entry ||= store.get entry_id
    end
    
    def attributes
      {
        'entry_id'          => entry_id,
        'store_cluster'     => store_cluster,
        'store_db_name'     => store_db_name,
        'store_collection'  => store_collection,
      }
    end
    
    def to_json(*args)
      attributes.to_json(*args)
    end
    
    def setup?
      entry_id &&
        store_cluster && store_db_name && store_collection
    end
    
    def store
      return unless store_cluster && store_db_name && store_collection
      Store.new store_cluster, store_db_name, store_collection
    end
  end
end