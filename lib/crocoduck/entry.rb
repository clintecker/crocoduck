require 'crocoduck/job'
require 'crocoduck/redis'
require 'crocoduck/resque'
require 'crocoduck/store'

module Crocoduck
  class Entry    
    attr_accessor :entry_id, :entry

    def initialize(entry_id)
      @entry_id = entry_id
    end

    def schedule(worker = Job)
      Resque.enqueue worker, entry_id
    end
    
    def entry
      @entry ||= store.get entry_id
    end
    
    def update(field, value)
      store.update entry_id, field, value
    end
    
    def store
      Store.new
    end
  end
end