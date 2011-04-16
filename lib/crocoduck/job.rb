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
    end
    
    # A thin wrapper around the real workhorse (do_work)
    def run
      return unless entry.setup?
      self.store = entry.store
      benchmark :info, "Running job" { do_work }
    rescue Exception =>e
      entry.job_status = 'failure'
      entry.save
      raise e
    else
      entry.job_status = 'success'
      entry.job_at = Time.now
      entry.save
    ensure
      # Clean up mongo and anything else
      store.close
    end
  end
end