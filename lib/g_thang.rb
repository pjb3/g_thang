require 'g_thang/http_server'

require 'rack/handler'
Rack::Handler.register("g_thang", "GThang::HttpServer")