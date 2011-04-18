require 'crocoduck/logging'
require 'crocoduck/entry'

module Crocoduck
  class Job
    @queue = :generic
    
    # Interface with Resque, finds the
    #  right entry object, instantiates
    #  a new job and calls `run` on it.
    def self.perform(entry_id)
      new(Entry.new entry_id).run
    end
    
    include Logging
    
    attr_accessor :entry, :store
  
    def initialize(entry)
      @entry = entry
    end
    
    def do_work
      # Do Something with entry
      entry.update "derp", "herp"
      # shorturl = shorturl.generate @entry.url
      # store.update entry_id, 'shorturl', shorturl
      # store.update entry_id, 'shorturl_status, job_status
    end
    
    # A thin wrapper around the real workhorse (do_work)
    def run
      store = entry.store
      return unless store.setup?
      return unless entry.entry
      benchmark :info, "Running job" do
        do_work
      end
    rescue Exception =>e
      # Clean up entry (not really needed in our case)
      raise e
    else
      # Do anything you'd need to do once the processing was finished
    ensure
      # Clean up mongo and anything else
      store.close
    end
  end
end