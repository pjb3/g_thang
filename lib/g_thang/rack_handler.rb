require 'rubygems'
require 'rack/rewindable_input'
require 'socket'

module GThang
  class RackHandler

    StatusCodeMapping = {
      200 => "OK",
      400 => "Bad Request",
      403 => "Forbidden",
      405 => "Method Not Allowed",
      411 => "Length Required",
      500 => "Internal Server Error"
    } 

    DefaultResponseHeaders = {
      "Connection" => "close",
      "Content-Type" => "text/html"
    }

    attr_reader :socket, :app, :env, :port

    def initialize(socket, app, port)
      @socket = socket
      @app = app
      @env = {
        "GATEWAY_INTERFACE" => "CGI/1.1", 
        "SCRIPT_NAME" => "",
        "SERVER_NAME" => Socket.gethostname,
        "SERVER_PORT" => port.to_s
      }
    end

    def handle_request
      return unless add_rack_variables_to_env
      return unless add_connection_info_to_env
      return unless add_request_line_info_to_env
      return unless add_headers_to_env
      send_response(app.call(env))
    end

    protected
    def add_rack_variables_to_env
      env["rack.version"] = [1,0]
      env["rack.url_scheme"] = "http"
      env["rack.input"] = Rack::RewindableInput.new(socket)
      env["rack.errors"] = $stderr
      env["rack.multithread"] = true
      env["rack.multiprocess"] = true
      env["rack.run_once"] = false
      true
    end
  
    def add_connection_info_to_env
      env["REMOTE_ADDR"] = socket.addr[3]
      env["REMOTE_HOST"] = socket.addr[2]
      true
    end

    def add_request_line_info_to_env
      if m = socket.gets.match(/^(\S+)\s+(\S+)\s+(\S+)/)
        env["REQUEST_METHOD"] = m[1].to_s.upcase
        path_info, query_string = m[2].to_s.split('?')
        env["PATH_INFO"] = path_info.to_s
        env["QUERY_STRING"] = query_string.to_s
        env["HTTP_VERSION"] = env["SERVER_PROTOCOL"] = m[3].to_s.upcase
        true
      else
        send_response(400)
        false
      end
    end

    def add_headers_to_env
      while (line=socket.gets) !~ /^(\n|\r)/
        if m = line.match(/^([\w-]+):\s*(.*)$/)
          env["HTTP_#{m[1].to_s.gsub(/-/,'_').upcase}"] = m[2]
        end
      end
      env["SERVER_NAME"] = env["HTTP_HOST"] if env["HTTP_HOST"]
      true
    end

    def send_response(response)
      case response
      when Integer
        socket << status_line(response)
      when Array
        socket << http_response(response)
      end
    end

    def status_line(response_code)
      response_message = StatusCodeMapping[response_code.to_i]
      unless response_message
        response_code = 500
        response_message = StatusCodeMapping[response_code.to_i]
      end
      "HTTP/1.1 #{response_code} #{response_message}\r\n"
    end

    # Expects response to be an Array that conforms to the Rack Spec
    #   [status_code (Integer), headers (Hash), body (Enumerable-ish)]
    # See: http://rack.rubyforge.org/doc/SPEC.html
    def http_response(response)
      status_code, headers, body = response
      http_response = status_line(status_code)
      DefaultResponseHeaders.merge(headers).each do |k,v|
        http_response << "#{k}: #{v}\r\n"
      end
      http_response << "\r\n"
      body.each do |s|
        http_response << s
      end
      http_response
    end

  end
end