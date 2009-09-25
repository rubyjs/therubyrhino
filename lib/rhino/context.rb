module Rhino
  
  def function(&impl)
    Function.new &impl
  end
  
  class Context

    class << self
      private :new
    end    
    
    def initialize(native)
      @native = native
    end
    
    def self.open
      J::ContextFactory.new.call do |native|
        yield new(native)
      end
    end
    
    def evaljs(str, scope = @native.initStandardObjects())
      begin
        @native.evaluateString(scope, str, "<eval>", 1, nil)
      rescue J::RhinoException => e
        raise Rhino::RhinoError, e
      end
    end
    
    def standard
      yield @native.initStandardObjects()
    end
    
  end
  
  class Function < J::BaseFunction
    def initialize(&block)
      @block = block
    end
    
    def call(cxt, scope, this, args)
      @block.call(*args)
    end
  end
    
    
  class RhinoError < StandardError
    def initialize(native)
      @native = native
    end
    
    def message
      @native.message
    end
    
    def javascript_backtrace
      @native.script_stack_trace
    end        
  end
end