
module Rhino
  module Ruby
    
    class Object < JS::ScriptableObject
      include JS::Wrapper

      # wrap an arbitrary (ruby) object
      def self.wrap(object, scope = nil)
        Rhino::Ruby.cache(object) { new(object, scope) }
      end

      def initialize(object, scope)
        super()
        @ruby = object
        if scope
          JS::ScriptRuntime.setObjectProtoAndParent(self, scope)
          setPrototype(JS::ScriptableObject.getObjectPrototype(scope)) unless getPrototype
        end
      end

      # abstract Object Wrapper#unwrap();
      def unwrap
        @ruby
      end

      # abstract String Scriptable#getClassName();
      def getClassName
        @ruby.class.name
      end

      def toString
        "[ruby #{getClassName}]" # [object User]
      end

      # override Object Scriptable#get(String name, Scriptable start);
      # override Object Scriptable#get(int index, Scriptable start);
      def get(name, start)
        if name.is_a?(String)
          if @ruby.respond_to?(name)
            method = @ruby.method(name)
            if method.arity == 0 && # check if it is an attr_reader
              ( @ruby.respond_to?("#{name}=") || @ruby.instance_variables.include?("@#{name}") )
              begin
                return Rhino.to_javascript(method.call, self)
              rescue => e
                raise Function.wrap_error(e)
              end
            else
              return Function.wrap(@ruby.method(name))
            end
          end
        end
        super
      end

      # override boolean Scriptable#has(String name, Scriptable start);
      # override boolean Scriptable#has(int index, Scriptable start);
      def has(name, start)
        if name.is_a?(String) 
          if @ruby.respond_to?(name) || 
             @ruby.respond_to?("#{name}=") # might have a writer but no reader
            return true
          end
        end
        super
      end

      # override void Scriptable#put(String name, Scriptable start, Object value);
      # override void Scriptable#put(int index, Scriptable start, Object value);
      def put(name, start, value)
        if name.is_a?(String)
          if @ruby.respond_to?(set_name = "#{name}=")
            return @ruby.send(set_name, Rhino.to_ruby(value))
          end
        end
        super
      end

      # override Object[] Scriptable#getIds();
      def getIds
        ids = []
        @ruby.public_methods(false).each do |name| 
          name = name[0...-1] if name[-1, 1] == '=' # 'foo=' ... 'foo'
          name = name.to_java # java.lang.String
          ids << name unless ids.include?(name)
        end
        super.each { |id| ids.unshift(id) }
        ids.to_java
      end

      # protected Object ScriptableObject#equivalentValues(Object value)
      def equivalentValues(other) # JS == operator
        other.is_a?(Object) && unwrap.eql?(other.unwrap)
      end

    end

    class Function < JS::BaseFunction

      # wrap a callable (Method/Proc)
      def self.wrap(callable, scope = nil)
        Rhino::Ruby.cache(callable) { new(callable, scope) }
      end

      def self.wrap_error(e)
        JS::WrappedException.new(org.jruby.exceptions.RaiseException.new(e))
      end

      def initialize(callable, scope)
        super()
        @callable = callable
        JS::ScriptRuntime.setFunctionProtoAndParent(self, scope) if scope
      end

      # override int BaseFunction#getLength()
      def getLength
        @callable.arity
      end

      # #deprecated int BaseFunction#getArity()
      def getArity
        getLength
      end

      # override String BaseFunction#getFunctionName()
      def getFunctionName
        @callable.is_a?(Proc) ? "" : @callable.name
      end

      def unwrap
        @callable
      end

      # protected Object ScriptableObject#equivalentValues(Object value)
      def equivalentValues(other) # JS == operator
        return false unless other.is_a?(Function)
        return true if unwrap == other.unwrap
        # Method.== does check if their bind to the same object
        # JS == means they might be bind to different objects :
        unwrap.to_s == other.unwrap.to_s # "#<Method: Foo#bar>"
      end

      # override Object ScriptableObject#getPrototype()
      def getPrototype
        unless proto = super
          #proto = ScriptableObject.getFunctionPrototype(getParentScope)
          #setPrototype(proto)
        end
        proto
      end

      # override Object BaseFunction#call(Context context, Scriptable scope, 
      #                                   Scriptable thisObj, Object[] args)
      def call(context, scope, this, args)
        rb_args = Rhino.args_to_ruby(args.to_a)
        begin
          result = @callable.call(*rb_args)
        rescue => e
          # ... correct wrapping thus it's try { } catch (e) works in JS :
          raise self.class.wrap_error(e)
        end
        Rhino.to_javascript(result, scope)
      end

    end

    class Constructor < Function
      include JS::Wrapper

      # wrap a ruby class as as constructor function
      def self.wrap(klass, scope = nil)
        new(klass, scope)
      end

      def initialize(klass, scope)
        super(klass.method(:new), scope)
        @klass = klass
      end

      def unwrap
        @klass
      end

      # override boolean Scriptable#hasInstance(Scriptable instance);
      def hasInstance(instance)
        return false unless instance
        return true if instance.is_a?(@klass)
        instance.is_a?(Object) && instance.unwrap.is_a?(@klass)
      end

    end

    def self.cache(key)
      fetch(key) || write(key, yield)
    end
    
    private
    
      # NOTE: just to get === comparison's working ...
      # if == is enough might be disabled by setting to nil
      @@cache = java.util.WeakHashMap.new
    
      def self.fetch(key)
        ref = @@cache && @@cache.get(key)
        ref ? ref.get : nil
      end

      def self.write(key, value)
        @@cache.put(key, java.lang.ref.WeakReference.new(value)) if @@cache
        value
      end
    
  end
  
  RubyObject = Ruby::Object
  RubyFunction = Ruby::Function
  RubyConstructor = Ruby::Constructor
  
end
