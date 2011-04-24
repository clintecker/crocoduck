### What is Crocoduck? ###
  
A specialized Resque Job system for mutating documents stored in MongoDB
  
### Goals ###
  
To make a nice, extensible Resque Job framework for altering MongoDB documents. These are referred to as ``Entry`` objects in this project.

The [``Job`` class](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/job.rb) itself is initialized with an [``Entry``](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/entry.rb) which
    knows about its own [``Store``](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/redis.rb). Crocoduck Jobs should inherit
    from the base ``Job`` class and override, at the very minimum, the ``do_work`` method.  This is where you will access data from the job's ``Entry`` instance, do some sort of process, and store the results back onto the ``Entry`` itself or somewhere else in the store.

The base Crocoduck job uses a Resque queue name of ``:crocoduck``.  This can be left alone or modified, depending on your Job/Queue needs.

In addition, a job author can override several other methods to handle circumstances specific to their project.  These are as follows:

* ``Job.setup``: This method runs just before ``do_work``, on the base Job class, we store the entry's store object on the Job itself for convenience.
* ``Job.handle_exception(e)``: By default the exception is merely raised for Resque to capture and log.  You might want to do some other work here, logging for instance.  You should probably always raise the exception for Resque's sake, unless you have a good reason.
* ``Job.finished``: This is run once the ``do_work`` has finished successfully.  The converse of ``handle_exception``.
* ``Job.cleanup``: This is run regardless of your job's success or failure.  By default we simply call ``Store.close``.
  
In an ideal world, one could install Crocoduck, and then build jobs on top of this class without having to do much beyond implementing their ``do_work`` code and possibly modifying the job's ``self.queue`` name.

### Environments ###
  
Your environment and your jobs must be imported for Resque to be able to use them when a matching job comes in on your specified queue.  An environment variable ``CROCODUCK_ENV`` is used to specify the name of the current operating environment.  This is currently only used to import our job classes and configure the ``Store`` options, but will later be expanded to the Redis configuration for Resque.  See the example

### The Datastore ###
  
Beyond the defaults for job processing outlined above, I hope that once work is completed, an author could swap out the default ``Store`` or override particular methods of ``Store`` to operate on non-MongoDB datastores.  MongoDB is the default because my personal needs for this project require Mongo.

As all Mongo environments are going to be highly specialized, the ``Store`` class can be configured prior to use. The ``Store`` class is highly specialized for simply retrieving a single documment, keyed off an ``entry_id`` which corresponds to ``_id`` in our Mongo collection. A [sample Rakefile](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/server.rb) has been included to show how one might configure the Store prior to spooling up Resque workers. The options are as follows:

* ``Crocoduck::Store.server_cluster``: This is an array of arrays corresponding your set of ``mongod``'s. These might take the form of: ``[['127.0.0.1', 27017]]`` in development or ``[['10.10.10.2', 27017], ['10.10.10.10', 27017], ['10.10.10.9', 27017]]`` in production.
* ``Crocoduck::Store.server_db``: This is the name of the database your workers will operate on, e.g. "ars".
* ``Crocoduck::Store.server_collection``: The name of the document collection your works will operate on, e.g. "entries".
* ``Crocoduck::Store.id_field``: The name of the field corresponding to our concept of "entry_id".  A field that uniquely identifies an entry document.

### Server ###
  
There is a small, Sinatra-based server that ships with this project.  This is really only useful for injecting artificial jobs into Resque for testing purposes.

### Resque/Redis Configuration ###
  
Right now this is hardcoded in [``redis.rb``](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/redis.rb), but will be extracted out so different Redis setups are possible—using Redis To Go for example.

### Logging and Benchmarking ###
  
A Crocoduck job should automatically have ``logger`` and ``benchmark`` methods included.  Use these as you see necessary, some examples:

    :001 > logger.warn "Could not connect to the shorturl webservice, details: ..."

    => I, [2011-04-24T14:28:32.687127 #97611]  INFO -- : Could not connect to the shorturl webservice, details: ...

  
    :002 > logger.debug "Connecting to xyz webservice"

    => D, [2011-04-24T14:30:45.410202 #97732]  DEBUG -- : Connecting to xyz webservice

    :003 > benchmark :info, "XYZ Job Finished" do
        do_work
    end

    => I, [2011-04-24T14:30:45.396550 #97732]  INFO -- : Ran Job (0.02146s)
    
### Want to know more? ###

Read the [annotated source code](https://clintecker.github.com/crocoduck/docs/lib/crocoduck/job.rb)!