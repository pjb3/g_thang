class GThangGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'g_thang.rb', 'script/g_thang', { :chmod => 0755 }
    end
  end
end