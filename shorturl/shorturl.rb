# shorturl.rb
#
#   Created by Vincent Foley on 2005-06-02
#
# Copyright (c) 2005, Vincent Foley
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "net/http"
require "cgi"
require "uri"
require "pp"

class ServiceNotAvailable < Exception
end

class InvalidService < Exception
end

class Service
  attr_accessor :port, :code, :method, :action, :field, :additional_fields, :block, :response_block

  # Intialize the service with a hostname (required parameter) and you
  # can override the default values for the HTTP port, expected HTTP
  # return code, the form method to use, the form action, the form
  # field which contains the long URL, and the block of what to do
  # with the HTML code you get.
  def initialize(hostname) # :yield: service
    @hostname = hostname
    @port = 80
    @code = 200
    @method = :post
    @action = "/"
    @field = "url"
    @additional_fields = {}

    if block_given?
      yield self
    end
  end

  # Now that our service is set up, call it with all the parameters to
  # (hopefully) return only the shortened URL.
  def call(url)
    Net::HTTP.start(@hostname, @port) { |http|
      @additional_fields[@field] = url
      params = @additional_fields.map { |p| 
        CGI::escape p[1]
        p.join('=')
      }.join('&')
      response = case @method
                 when :post: http.post(@action, params)
                 when :get: http.get("#{@action}?#{params}")
                 end
      if response.code == @code.to_s
        @response_block ? @response_block.call(response) : @block.call(response.read_body)
      end
    }
  rescue Errno::ECONNRESET => e
    raise ServiceNotAvailable, e.to_s, e.backtrace
  end
end

class ShortURL
  # Hash table of all the supported services.  The key is a symbol
  # representing the service (usually the hostname minus the .com,
  # .net, etc.)  The value is an instance of Service with all the
  # parameters set so that when +instance+.call is invoked, the
  # shortened URL is returned.
  @@services = {
    :bitly => Service.new("api.bitly.com") { |s|
      s.method = :post
      s.action = "/v3/shorten"
      s.field  = "longUrl"
      s.additional_fields = {
        :format => 'txt',
        :apiKey => ENV['BITLY_KEY']||'',
        :login => ENV['BITLY_LOGIN']||''
      }
      s.block  = lambda { |body| URI.extract(body).grep(/bit\.ly/)[0] }
    },
    
    :arstch => Service.new('arst.ch') { |s|
      s.method = :get
      s.action = "/api/shorten/"
      s.field  = "url"
      s.block  = lambda { |body| URI.extract(body).grep(/arst\.ch/)[0] }
    },
  }

  @@valid_services = @@services.keys

  def self.valid_services
    @@valid_services
  end

  # call-seq:
  #   ShortURL.shorten("http://mypage.com") => Uses RubyURL
  #   ShortURL.shorten("http://mypage.com", :tinyurl)
  def self.shorten(url, service = :bitly)
    if valid_services.include? service
      @@services[service].call(url)
    else
      raise InvalidService
    end
  end
end