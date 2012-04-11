
module Rhino

  class JSError < StandardError
    
    def initialize(native)
      @native = native # NativeException wrapping a Java Throwable
      message = value ? value : ( cause ? cause.details : @native )
      super(message)
    end
    
    # most likely a Rhino::JS::JavaScriptException
    def cause
      @native.respond_to?(:cause) ? @native.cause : nil
    end

    def value
      return @value if defined?(@value)
      if cause.respond_to?(:value) # e.g. JavaScriptException.getValue
        @value = cause.value
      elsif ( unwrap = self.unwrap ) && unwrap.respond_to?(:value)
        @value = unwrap.value
      else
        @value = nil
      end
    end
    
    def unwrap
      return @unwrap if defined?(@unwrap)
      cause = self.cause
      if cause && cause.is_a?(JS::WrappedException) 
        e = cause.getWrappedException
        if e && e.is_a?(Java::OrgJrubyExceptions::RaiseException)
          @unwrap = e.getException
        else
          @unwrap = e
        end
      else
        @unwrap = nil
      end
    end
    
    def javascript_backtrace
      cause.is_a?(JS::RhinoException) ? cause.getScriptStackTrace : nil
    end
    
  end
  
end
