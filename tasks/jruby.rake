if RUBY_PLATFORM =~ /java/
  require 'java'
else
  puts "Java RubyGem only! You are not running within jruby."
  puts "Try: jruby -S rake #{ARGV.join(' ')}"
  exit(1)
end
