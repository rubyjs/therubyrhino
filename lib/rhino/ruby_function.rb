
module Rhino
  class RubyFunction < J::BaseFunction
    
    def initialize(callable)
      super()
      @callable = callable
    end
    
    def call(cxt, scope, this, args)
      To.javascript @callable.call(*args.map {|a| To.ruby(a)})
    end
  end
end