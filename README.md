### System for building reusable Resque Jobs ###
#### That operate on similar kinds of Documents/Articles/Entries####

This is currently in the prototyping stage, but my goal here is to build:

* A template for building workers that operate on a conceptual object "entry"
* Workers will retrieve the data comprising this entry
* These workers encapsulate the work they'll do on said objects
* Persistence is abstracted down to a Store class which can be swapped out or modified. By default I am using Mongo DB as the document store.
* Entries carry around enough information to reconstitute themselves as some later point in time (by Resque), before they perform their work.


### Unresolved Issues ###

* How to let Resque know what kind of worker to use?  Entry could know how to enqueue itself, but it would need to know the class of the Job that needs to be used.
* ``crocoduck/job.rb`` is intended to be extended and have the ``do_work`` method overridden.  Maybe this isn't the best way?