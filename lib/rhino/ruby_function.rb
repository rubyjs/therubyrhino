
module Rhino
  class RubyFunction < JS::BaseFunction
    
    def initialize(callable)
      super()
      @callable = callable
    end
    
    def call(cxt, scope, this, args)
      To.javascript @callable.call(*Array(args).map {|a| To.ruby(a)})
    end
  end
end