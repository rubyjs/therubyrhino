require 'java'

module Rhino
  
   # allow for rhino.jar overrides for "experimental" jrubyists 
   # fallback to rhino/jar_path provided therubyrhino_jar gem :
  require 'rhino/jar_path' unless defined?(Rhino::JAR_PATH)
  load Rhino::JAR_PATH
  
  # This module contains all the native Rhino objects implemented in Java
  # e.g. Rhino::JS::NativeObject # => org.mozilla.javascript.NativeObject
  module JS
    include_package "org.mozilla.javascript"
    module Regexp
      include_package "org.mozilla.javascript.regexp"
    end
  end
  
end

require 'rhino/version'
require 'rhino/wormhole'
Rhino.extend Rhino::To

require 'rhino/object'
require 'rhino/context'
require 'rhino/error'
require 'rhino/rhino_ext'
require 'rhino/ruby'
require 'rhino/ruby/access'
require 'rhino/deprecations'
