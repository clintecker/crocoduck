require 'sinatra/base'
require 'crocoduck/entry'

module Crocoduck
  class Server < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get "/" do
      erb :index
    end

    post "/" do
      entry_id = params[:entry_id]
      entry = Entry.new entry_id
      entry.schedule
      redirect "/"
    end
  end
end
