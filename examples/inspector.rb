require 'rubygems'
require 'g_thang'

app = lambda{|env| [200, {"Content-Type" => "text/plain"}, 
  env.keys.sort.map{|k| "#{k}: #{env[k]}"}.join("\n")] }

GThang::HttpServer.run app, :Port => 8080