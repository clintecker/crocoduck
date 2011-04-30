require 'crocoduck/job'

Crocoduck::Store.server_cluster = [['127.0.0.1', 27017]]
Crocoduck::Store.server_db = 'testing'
Crocoduck::Store.server_collection = 'entries'
#Crocoduck::Store.id_field = "_id"