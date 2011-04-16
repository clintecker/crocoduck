require 'crocoduck/job'

module Crocoduck
  class Entry
    def self.find(entry_id)
      # Get entry from mongo
      # Initialize this object
    end

    attr_accessor :entry_id, :job_status, 
                  :job_at, :store_servers, 
                  :store_db_name

    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send "#{key}=", value
      end
    end

    def save
      # Put everything back into mongo
      # Append job status / time to log
    end
    
    def schedule
      Resque.enqueue Job, entry_id
    end
    
    def attributes
      {
        'entry_id'      => entry_id,
        'job_status'    => job_status,
        'job_at'        => job_at,
        'store_servers' => store_servers,
        'store_db_name' => store_db_name,
      }
    end
    
    def to_json(*args)
      attributes.to_json(*args)
    end
    
    def setup?
      entry_id &&
        store_servers && store_db_name
    end
    
    def store
      return unless store_servers && store_db_name
      Store.new store_servers, store_db_name
    end
  end
end