# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{therubyrhino}
  s.version = "1.72.6"
  s.platform = %q{jruby}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell"]
  s.date = %q{2009-11-30}
  s.description = %q{Embed the Mozilla Rhino Javascript interpreter into Ruby}
  s.email = ["cowboyd@thefrontside.net"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/rhino.rb", "lib/rhino/context.rb", "lib/rhino/java.rb", "lib/rhino/native_function.rb", "lib/rhino/native_object.rb", "lib/rhino/object.rb", "lib/rhino/rhino-1.7R2.jar", "lib/rhino/ruby_function.rb", "lib/rhino/ruby_object.rb", "lib/rhino/wormhole.rb", "script/console", "script/destroy", "script/generate", "spec/rhino/context_spec.rb", "spec/rhino/native_object_spec.rb", "spec/rhino/ruby_object_spec.rb", "spec/rhino/wormhole_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/jruby.rake", "tasks/rspec.rake", "therubyrhino.gemspec"]
  s.homepage = %q{http://github.com/cowboyd/therubyrhino}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{therubyrhino}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Embed the Rhino Javascript engine into JRuby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
