source :rubygems

gemspec :name => "therubyrhino"

group :test do
  # NOTE: some specs might be excluded @see #spec/spec_helper.rb
  gem 'redjs', :git => 'git://github.com/cowboyd/redjs.git', :group => :test,
               :ref => "0d844f066666f967a78b20beb164c52d9ac3f5ca"
  #gem 'redjs', :path => '../redjs', :group => :test
  
  gem 'therubyrhino_jar', '1.7.4'
end