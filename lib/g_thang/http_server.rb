require 'gserver'
require 'cgi'
require 'g_thang/rack_handler'

module GThang
  class HttpServer < GServer

    attr_reader :port, :rack_app

    def initialize(options={})
      @port = options[:Port] || 8080
      @rack_app = options[:rack_app]
      super(@port)
    end

    def serve(io)
      RackHandler.new(io, rack_app, port).handle_request
    rescue Exception => ex
      response = "HTTP/1.1 500 Internal Server Error\r\n"
      response << "Connection: close\r\n"
      response << "Content-Type: text/html\r\n\r\n"
      response << "<html><head><title>Internal Server Error</title></head><body>\n"
      response << "<h1>Internal Server Error</h1>\n<pre>\n"
      response << h("#{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n    ")}\n")
      response << "</pre></body></html>"
      io << response
    end

    def h(str)
      CGI::escapeHTML(str.to_s)
    end

    def self.run(app, options={})
      server = new({:rack_app => app}.merge(options))
      server.start
      server.join
    end

  end
end