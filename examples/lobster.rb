require 'rubygems'
require 'g_thang'
require 'rack/lobster'

GThang::HttpServer.run Rack::Lobster.new, :Port => 8080