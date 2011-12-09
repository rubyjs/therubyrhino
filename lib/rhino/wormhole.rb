
module Rhino
  module To

    def to_ruby(object)
      case object
      when JS::Scriptable::NOT_FOUND, JS::Undefined then nil
      when JS::Wrapper           then object.unwrap
      when JS::NativeArray       then array_to_ruby(object)
      when JS::NativeDate        then Time.at(object.getJSTimeValue / 1000)
      else object
      end
    end

    def to_javascript(object, scope = nil)
      case object
      when NilClass              then object
      when String, Numeric       then object
      when TrueClass, FalseClass then object
      when Array                 then array_to_javascript(object, scope)
      when Hash                  then hash_to_javascript(object, scope)
      when Proc, Method          then RubyFunction.new(object)
      when JS::Scriptable        then object
      else RubyObject.new(object)  
      end
    end

    def args_to_ruby(args)
      args.map { |arg| to_ruby(arg) }
    end
    
    def args_to_javascript(args, scope = nil)
      args.map { |arg| to_javascript(arg, scope) }.to_java
    end
    
    private
    
      def array_to_ruby(js_array)
        js_array.length.times.map { |i| to_ruby( js_array.get(i, js_array) ) }
      end

      def array_to_javascript(rb_array, scope = nil)
        if scope 
          raise "no current context" unless context = JS::Context.getCurrentContext
          context.newArray(scope, rb_array.to_java)
        else
          JS::NativeArray.new(rb_array.to_java)
        end
      end

      def hash_to_javascript(rb_hash, scope = nil)
        js_object = 
          if scope 
            raise "no current context" unless context = JS::Context.getCurrentContext
            context.newObject(scope)
          else
            JS::NativeObject.new
          end
        # JS::NativeObject implements Map put it's #put does :
        # throw new UnsupportedOperationException(); thus no []=
        rb_hash.each_pair do |key, val| 
          js_val = to_javascript(val, scope)
          JS::ScriptableObject.putProperty(js_object, key.to_s, js_val)
        end
        js_object
      end
    
  end
end
