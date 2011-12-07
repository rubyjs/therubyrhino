require 'java'

require 'rhino/rhino-1.7R3.jar'

module Rhino
  
  # This module contains all the native Rhino objects implemented in Java
  # e.g. Rhino::JS::NativeObject # => org.mozilla.javascript.NativeObject
  module JS
    import "org.mozilla.javascript"
    
    module Regexp
      import "org.mozilla.javascript.regexp"
    end
    
  end
  
  J = JS # (deprecated) backward compatibility
  
end

require 'rhino/object'
require 'rhino/context'
require 'rhino/wormhole'
require 'rhino/ruby_object'
require 'rhino/ruby_function'
require 'rhino/rhino_ext'
