require 'java'
require 'rhino/rhino-1.7R2.jar'

module Rhino
  module J
    import "org.mozilla.javascript"
  end
end

unless Object.method_defined?(:tap)
  class Object
    def tap
      yield self
      self
    end
  end
end