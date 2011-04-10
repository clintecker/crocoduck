require 'worker'
require 'exceptional'

Exceptional::Config.load("config/exceptional.yml")

Exceptional.rescue_and_reraise do
  Worker.mongo = Mongo::Connection.multi([['10.10.10.2', 27017], ['10.10.10.10', 27017], ['10.10.10.9', 27017]]).db('ars')
  Worker.beanstalk = Beanstalk::Pool.new(['10.10.10.11:11300'], 'discussion')
  Worker.debug = true if ENV['CROCODUCK_ENV'] = 'development'
  Worker.restart_file_path = "./tmp/restart.txt"
  Worker.worker_log = "./tmp/worker.log"
  Worker.run
end
