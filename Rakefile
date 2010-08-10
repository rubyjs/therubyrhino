require 'rubygems'
require './lib/rhino'
Gem::Specification.new do |gemspec|
  $gemspec = gemspec
  gemspec.name = gemspec.rubyforge_project = "therubyrhino"
  gemspec.version = Rhino::VERSION
  gemspec.summary = "Embed the Rhino JavaScript interpreter into JRuby"
  gemspec.description = "Call javascript code and manipulate javascript objects from ruby. Call ruby code and manipulate ruby objects from javascript."
  gemspec.email = "cowboyd@thefrontside.net"
  gemspec.homepage = "http://github.com/cowboyd/therubyrhino"
  gemspec.authors = ["Charles Lowell"]
  gemspec.extra_rdoc_files = ["README.rdoc"]
  gemspec.files = Rake::FileList.new("**/*").tap do |manifest|
    manifest.exclude "*.gem"
  end
end

desc "Build gem"
task :gem => :gemspec do
  Gem::Builder.new($gemspec).build
end

desc "build the gemspec"
task :gemspec => :clean do
  File.open("#{$gemspec.name}.gemspec", "w") do |f|
    f.write($gemspec.to_ruby)
  end
end

task :clean do
  sh "rm -rf *.gem"
end

for file in Dir['tasks/*.rake']
  load file
end
