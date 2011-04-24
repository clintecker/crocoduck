# `Job` is a class that is intended to be extended to do meaningful work. A
#  Crocoduck Job is simply a Resque style job that knows about its own
#  datastore and an entry object (Mongo Document when using the supplied
#  ``store`` class).
require 'crocoduck/logging'
require 'crocoduck/entry'

module Crocoduck
  class Job
    # Override the value of ``@queue`` to specify which resque workers will 
    # process this job.
    @queue = :generic
    
    # ``perform`` is the method called by Resque. A Crocoduck job only expects
    # an ``entry_id`` corresponding to a record in your Mongo store.  An
    # ``Entry`` is instantiated with said ``entry_id`` and passed to a new
    # instance of this job and run is called on it.
    def self.perform(entry_id)
      new(Entry.new entry_id).run
    end
    
    include Logging
    
    attr_accessor :entry, :store
    
    def initialize(entry)
      @entry = entry
    end
    
    # The ``do_work`` method should be overridden to do some kind of work on
    # the stored entry object.
    def do_work
      logger.info "Starting work"
      # Do Something with entry
      # entry.update "derp", "herp"
      logger.info entry.entry['style_status']
      # shorturl = shorturl.generate @entry.url
      # store.update entry_id, 'shorturl', shorturl
      # store.update entry_id, 'shorturl_status, job_status
      logger.info "Ending work"
    end
    
    # If you job failed, you can do something interesting here.  Generally
    # you will want to ultimately raise the exception so Resque can track it.
    def handle_job_exception(e)
      raise e
    end
    # This method will be called immediately before sanity checks and before
    # ``do_work`` is called.
    def setup
      @store = entry.store
      logger.info "Job is setup"
    end
    
    # This method will be called once ``do_work`` has finished successfully.
    # Do anything you'd need to do once the processing was finished
    # properly (save out your entry, update stats, et cetera).
    def finished
      logger.info "Job finished successfully"
    end
    
    # This method will always be called, regardless of the failure or
    # success of your job.
    def cleanup
      @store.close
      logger.info "Job cleaned up"
    end
    
    # The ``run`` method is a thin wrapper around ``do_work`` which lets us
    # do some setup, benchmark the work we'll do, cleanly handle exceptions if
    # thrown by the ``do_work`` call, and clean up our store and entry on
    # success.
    def run
      setup
      # The job will not process anything unless our datastore has enough
      # information to connect and if a valid entry object could be fetched
      # from the store.
      return unless store.setup?
      return unless entry.entry
      benchmark :info, "Running job" do
        do_work
      end
    # Exception handling is parceled out to ``Job`` methods you can override
    # to handle cleanup specific to your task.
    rescue Exception => e
      handle_exception e
    else
      finished
    ensure
      cleanup
    end
  end
end