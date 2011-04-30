# The Entry object represents a document retrieved from
# the datastore.  By default this is a MongoDB document.
require 'crocoduck/job'
require 'crocoduck/redis'
require 'crocoduck/resque'
require 'crocoduck/store'

module Crocoduck
  class Entry    
    attr_accessor :entry_id, :entry, :store

    def initialize(entry_id)
      @entry_id = entry_id
    end

    # A quick way to start work on an Entry is to do something
    # like the following
    #
    #     >>> e = Entry.new(53029).schedule(ShortUrlJob)
    def schedule(worker = Job)
      Resque.enqueue worker, entry_id
    end
    
    # Rather than access ``Crocoduck::Entry.entry`` directly, one can do the
    # following:
    #
    #     :001 > e = Crocoduck::Entry.new(50039)
    #      => #<Crocoduck::Entry:0x101611938 @entry_id=50039> 
    #     :002 > e["url"]
    #      => "/apple/news/2011/04/this-is-not-a-real-article.ars"
    def [](key)
      if entry.key? key
        entry[key]
      else
        nil
      end
    end
    
    # This hasn't been field tested yet, but ``update`` should be a
    # convienance method to manipulate a field on the entry document
    # stored here.  If a job needed to store results or data on a
    # different document, she could use the ``Crocoduck::Store.update`` method
    # directly.
    def update(field, value)
      store.update entry_id, field, value
    end
    
    def close
      store.close
    end
    
    private
    
    # When the ``entry`` property of an Entry object is accessed
    # we attempt to retrieve the document from the store, save it
    # on our object, and then return it.  Further accesses get the
    # cached copy of the document.
    def entry
      @entry ||= store.get entry_id
    end
    
    # Accessing ``Crocoduck::Entry.store`` gets you a new store object to work with.
    def store
      @store ||= Store.new
    end
  end
end