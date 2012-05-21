module Rhino

  class JSError < StandardError

    def initialize(native)
      @native = native # NativeException wrapping a Java Throwable
      message = value ? value : ( cause ? cause.details : @native )
      super(message)
    end

    def inspect
      "#<#{self.class.name}: #{message}>"
    end

    # most likely a Rhino::JS::JavaScriptException
    def cause
      @cause ||= if @native.respond_to?(:cause) && @native.cause
        @native.cause
      else
        @native.is_a?(JS::RhinoException) ? @native : nil
      end
    end

    def value
      @value ||= if cause.respond_to?(:value) # e.g. JavaScriptException.getValue
        cause.value
      elsif ( unwrap = self.unwrap ) && unwrap.respond_to?(:value)
        unwrap.value
      end
    end

    def unwrap
      cause = self.cause
      @unwrap ||= if cause && cause.is_a?(JS::WrappedException)
        e = cause.getWrappedException
        if e && e.is_a?(Java::OrgJrubyExceptions::RaiseException)
          e.getException
        else
          e
        end
      end
    end

    def backtrace
      if js_backtrace = javascript_backtrace
        js_backtrace.push(*super)
      else
        super
      end
    end

    def javascript_backtrace(keep_elements = false)
      if cause.is_a?(JS::RhinoException)
        cause.getScriptStack.map do |element| # ScriptStackElement[]
          keep_elements ? element : element.to_s
        end
      else
        nil
      end
    end

    Rhino::JS::RhinoException.useMozillaStackStyle(false)

  end

end
