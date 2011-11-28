require 'java'
require 'rhino/rhino-1.7R3.jar'

module Rhino
  # This module contains all the native Rhino objects implemented in Java
  # e.g. 
  #   Rhino::J::NativeObject # => org.mozilla.javascript.NativeObject
  module J
    import "org.mozilla.javascript"

    module Regexp
      import "org.mozilla.javascript.regexp"
    end
  end
end

unless Object.method_defined?(:tap)
  class Object #:nodoc:
    def tap
      yield self
      self
    end
  end
end
