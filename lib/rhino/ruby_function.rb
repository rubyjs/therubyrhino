
module Rhino
  class RubyFunction < JS::BaseFunction
    
    def initialize(callable)
      super()
      @callable = callable
    end
    
    def unwrap
      @callable
    end
    
    # override Object BaseFunction#call(Context context, Scriptable scope, 
    #                                   Scriptable thisObj, Object[] args)
    def call(context, scope, this, args)
      rb_args = Rhino.args_to_ruby(args.to_a)
      begin
        result = @callable.call(*rb_args)
      rescue => e
        # ... correct wrapping thus it's try { } catch (e) works in JS :
        
        raise JS::WrappedException.new(org.jruby.exceptions.RaiseException.new(e))
        
      end
      Rhino.to_javascript(result, scope)
    end
    
    # protected Object ScriptableObject#equivalentValues(Object value)
    def equivalentValues(other) # JS == operator
      return false unless other.is_a?(RubyFunction)
      return true if unwrap == other.unwrap
      # Method.== does check if their bind to the same object
      # JS == means they might be bind to different objects :
      unwrap.to_s == other.unwrap.to_s # "#<Method: Foo#bar>"
    end
    
  end
end