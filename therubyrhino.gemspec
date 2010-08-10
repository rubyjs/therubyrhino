# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{therubyrhino}
  s.version = "1.72.7.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell"]
  s.date = %q{2010-08-10}
  s.description = %q{Call javascript code and manipulate javascript objects from ruby. Call ruby code and manipulate ruby objects from javascript.}
  s.email = %q{cowboyd@thefrontside.net}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["History.txt", "lib", "Rakefile", "README.rdoc", "spec", "tasks", "therubyrhino.gemspec", "lib/rhino", "lib/rhino.rb", "lib/rhino/context.rb", "lib/rhino/java.rb", "lib/rhino/native_function.rb", "lib/rhino/native_object.rb", "lib/rhino/object.rb", "lib/rhino/rhino-1.7R2.jar", "lib/rhino/ruby_function.rb", "lib/rhino/ruby_object.rb", "lib/rhino/wormhole.rb", "spec/redjs", "spec/redjs_helper.rb", "spec/rhino", "spec/spec.opts", "spec/spec_helper.rb", "spec/redjs/jsapi_spec.rb", "spec/redjs/README.txt", "spec/rhino/context_spec.rb", "spec/rhino/wormhole_spec.rb", "tasks/jruby.rake", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/cowboyd/therubyrhino}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{therubyrhino}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Embed the Rhino JavaScript interpreter into JRuby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
