require 'rubygems'
require 'g_thang'
require 'rack'

root = File.expand_path("~")

GThang::HttpServer.run(
  Rack::CommonLogger.new(
    Rack::Lint.new(
      Rack::Directory.new(root, Rack::File.new(root)))),
  :Port => 8080)