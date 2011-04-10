require 'rubygems'
require "bundler"
Bundler.setup

require 'shorturl'
require 'beanstalk-client'
require 'mongo'

class Worker
  class << self
    attr_accessor :debug, :worker_log, :restart_file_path, :mongo, :beanstalk
  end

  def self.beanstalk
    @beanstalk ||= Beanstalk::Pool.new(['127.0.0.1:11300'], 'discussion')
  end
  
  def self.mongo
    @mongo ||= Mongo::Connection.new.db('ars_api_development')
  end
  
  def self.set_log_file
    $stdout = File.new(@worker_log, 'a')
    if @debug
      $stdout.sync = true
    end
  end

  def self.entries
    @entries ||= mongo.collection('entries')
  end

  def self.restart_file_mtime
    (@restart_file_path && File.exist?(@restart_file_path) && File.mtime(@restart_file_path))
  end
  
  def self.run
    set_log_file
    last_modified = restart_file_mtime
    puts "#{Time.now} - Restart file last modified #{last_modified}"
    loop do
      job = beanstalk.reserve
      errors = []
      
      unless restart_file_mtime == last_modified
        puts("#{Time.now} - This script is stale, quitting")
        job.release
        Process.exit
        break
      end
      
      puts "#{Time.now} - Received discussion job: #{job.body}"
      
      
      # Parse message.  All we need is the entry id
      msg = job.body.split
      # Get all the information for the entry
      puts "#{Time.now} - Retrieving entry with id #{msg.first}"
      e = get_entry(msg.first)
      # Bail out if we got nothing or if there's already a shorturl
      if e.nil?
        puts "#{Time.now} - Entry id #{msg.first} is invalid" if e.nil? 
        job.delete
        next
      elsif e.has_key?('phpbb_id') || (e.has_key?('discussion_url') && !e['discussion_url'].empty? && e['discussion_url'] != false)
        puts "#{Time.now} - #{msg.first} already has an old-style discussion."
        job.delete
        next
      elsif e.has_key?('discussion') && e['discussion']['status']['success']
        puts "#{Time.now} - #{msg.first} already has new-style discussion: #{e['discussion']['url']}"
        job.delete
        next
      end
      
      # Get/Produce the discussion id for the entry
      entry_discussion = discussion_for e, errors
      puts "#{Time.now} - Discussion ID retreived #{entry_discussion} for entry #{msg.first}"
      puts "#{Time.now} - Errors: #{errors.join(", ")}" if errors.length

      status = {'success' => errors.length == 0}
      status['errors'] = errors if errors.length > 0
      status['compiled_at'] = Time.now.to_s
      entries.update({'_id' => e['_id']}, {'$set' => {'shorturl' => { 'url' => entry_shorturl, 'status' => status } }}, :safe => true)
      puts "#{Time.now} - Stored shorturl_status for entry #{e['_id']}: #{status['success']}"
      job.delete
    end
  end

  def self.get_entry(id)
    entries.find_one({'_id' => id.to_i})
  end
  
  def self.shorturl_for(entry, errors = [])
    full_url = "http://arstechnica.com#{entry['url']}"
    begin
      short_url = ShortURL.shorten(full_url, :arstch)
    rescue ServiceNotAvailable
      errors << "ShortURL Service Not Available"
    rescue InvalidService
      errors << "Invalid ShortURL Service"
    end
    short_url ||= nil
  end
end
