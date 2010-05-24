require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/rhino'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'therubyrhino' do
  self.developer 'Charles Lowell', 'cowboyd@thefrontside.net'
  self.rubyforge_name   = self.name 
  self.summary          = "Embed the Rhino Javascript engine into JRuby"

  self.spec_extras['platform'] = 'jruby' # JRuby gem created, e.g. therubyrhino-X.Y.Z-jruby.gem
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

