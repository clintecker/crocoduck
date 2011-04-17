require 'crocoduck/logging'

module Crocoduck
  class Job
    @queue = :generic
    
    # Interface with Resque, finds the
    #  right entry object, instantiates
    #  a new job and calls `run` on it.
    def perform(entry_id)
      if entry = Entry.find(entry_id)
        new(entry).run
      end
    end
    
    include Logging
    
    attr_accessor :entry
  
    def initialize(entry)
      @entry = entry
    end
    
    def do_work
      # Do Something with entry
      # shorturl = shorturl.generate @entry.url
      # store.update entry_id, 'shorturl', shorturl
      # store.update entry_id, 'shorturl_status, job_status
      
    end
    
    # A thin wrapper around the real workhorse (do_work)
    def run
      return unless entry.setup?
      self.store = entry.store
      benchmark :info, "Running job" { do_work }
    rescue Exception =>e
      entry.save
      raise e
    else
      entry.save
    ensure
      # Clean up mongo and anything else
      store.close
    end
  end
end