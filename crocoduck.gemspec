Gem::Specification.new do |s|
  s.name      = 'crocoduck'
  s.version   = '0.0.1'
  s.date      = '2011-04-23'

  s.homepage    = "https://github.com/clintecker/crocoduck"
  s.summary     = "Resque Jobs working on MongoDB"
  s.description = <<-EOS
    Crocoduck is a Resque job system that seeks to model the pattern of mutating MongoDB documents.
  EOS

  s.files = Dir['lib/**/*.rb']

  s.add_dependency 'redis'
  s.add_dependency 'resque'
  s.add_dependency 'sinatra'
  s.add_dependency 'mongo'
  
  s.authors = ["Clint Ecker"]
  s.email   = "me@clintecker.com"
end