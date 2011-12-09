
module Rhino

  class JSError < StandardError
    
    def initialize(native)
      @native = native # NativeException wrapping a Java Throwable
    end

    # most likely a Rhino::JS::JavaScriptException
    def cause
      @native.respond_to?(:cause) ? @native.cause : nil
    end
    
    def message
      cause ? cause.details : @native.to_s
    end

    def javascript_backtrace
      cause.is_a?(JS::RhinoException) ? cause.getScriptStackTrace : nil
    end
    
  end
  
end
