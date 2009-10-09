require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "g_thang"
    gem.summary = %Q{A Rack-Compliant HTTP Server Implemented with GServer}
    gem.description = gem.summary
    gem.email = "mail@paulbarry.com"
    gem.homepage = "http://github.com/pjb3/g_thang"
    gem.authors = ["Paul Barry"]
    gem.files = ["lib/g_thang.rb"]
    gem.files += ["lib/g_thang/**/**"]
    gem.files += ["rails_generators/**/**"]
    gem.test_files = []
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

