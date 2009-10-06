module Rhino
  
  def function(&impl)
    Function.new &impl
  end
  
  class Context

    class << self
      def open
        J::ContextFactory.new.call do |native|
          yield new(native)
        end
      end
      
      def open_std(options = {})
        open do |cxt|
          yield cxt, cxt.init_standard_objects(options)
        end
      end
                
      private :new
    end    
    
    def initialize(native) #:nodoc:
      @native = native
    end
        
    def init_standard_objects(options = {})
      NativeObject.new(@native.initStandardObjects(nil, options[:sealed] == true)).tap do |objects|
        unless options[:java]
          for package in ["Packages", "java", "org", "com"]
            objects.j.delete(package)
          end
        end
      end
    end
    
    def evaljs(str, scope = @native.initStandardObjects())
      begin
        To.ruby @native.evaluateString(To.javascript(scope), str, "<eval>", 1, nil)
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
      @native.getScriptStackTrace()
    end        
  end
end