
module Rhino
  module Ruby
    
    # shared JS::Scriptable implementation
    module Scriptable
      
      # override Object Scriptable#get(String name, Scriptable start);
      # override Object Scriptable#get(int index, Scriptable start);
      def get(name, start)
        if name.is_a?(String)
          if unwrap.respond_to?(name)
            method = unwrap.method(name)
            if method.arity == 0 && # check if it is an attr_reader
              ( unwrap.respond_to?("#{name}=") || unwrap.instance_variables.include?("@#{name}") )
              begin
                return Rhino.to_javascript(method.call, self)
              rescue => e
                raise Function.wrap_error(e)
              end
            else
              return Function.wrap(unwrap.method(name))
            end
          elsif unwrap.respond_to?("#{name}=")
            return nil # it does have the property but is non readable
          end
        end
        # try [](name) method :
        if unwrap.respond_to?(:'[]') && unwrap.method(:'[]').arity == 1
          if value = unwrap[name]
            return Rhino.to_javascript(value, self)
          end
        end
        super
      end

      # override boolean Scriptable#has(String name, Scriptable start);
      # override boolean Scriptable#has(int index, Scriptable start);
      def has(name, start)
        if name.is_a?(String) 
          if unwrap.respond_to?(name) || 
             unwrap.respond_to?("#{name}=") # might have a writer but no reader
            return true
          end
        end
        # try [](name) method :
        if unwrap.respond_to?(:'[]') && unwrap.method(:'[]').arity == 1
          return true if unwrap[name]
        end
        super
      end

      # override void Scriptable#put(String name, Scriptable start, Object value);
      # override void Scriptable#put(int index, Scriptable start, Object value);
      def put(name, start, value)
        if name.is_a?(String)
          if unwrap.respond_to?(set_name = "#{name}=")
            return unwrap.send(set_name, Rhino.to_ruby(value))
          end
        end
        # try []=(name, value) method :
        if unwrap.respond_to?(:'[]=') && unwrap.method(:'[]=').arity == 2
          return unwrap[name] = Rhino.to_ruby(value)
        end
        super
      end
      
      # override Object[] Scriptable#getIds();
      def getIds
        ids = []
        unwrap.public_methods(false).each do |name| 
          name = name[0...-1] if name[-1, 1] == '=' # 'foo=' ... 'foo'
          name = name.to_java # java.lang.String
          ids << name unless ids.include?(name)
        end
        super.each { |id| ids.unshift(id) }
        ids.to_java
      end
      
    end
    
    class Object < JS::ScriptableObject
      include JS::Wrapper
      include Scriptable
      
      # wrap an arbitrary (ruby) object
      def self.wrap(object, scope = nil)
        Rhino::Ruby.cache(object) { new(object, scope) }
      end

      def initialize(object, scope)
        super()
        @ruby = object
        @scope = scope
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

      # protected Object ScriptableObject#equivalentValues(Object value)
      def equivalentValues(other) # JS == operator
        other.is_a?(Object) && unwrap.eql?(other.unwrap)
      end

      # override Scriptable Scriptable#getPrototype();
      def getPrototype
        # TODO needs to be revisited to that ruby.constructor works ...
        if ! (proto = super) && @scope
          JS::ScriptRuntime.setObjectProtoAndParent(self, @scope)
          unless proto = super
            setPrototype(proto = JS::ScriptableObject.getObjectPrototype(@scope))
          end
        end
        proto
      end
      
    end

    class Function < JS::BaseFunction
      include Scriptable
      
      # wrap a callable (Method/Proc)
      def self.wrap(callable, scope = nil)      
        # NOTE: === seems 'correctly' impossible without having multiple 
        # instances of the 'same' wrapper function (even with an UnboundMethod), 
        # suppose :
        # 
        #     var foo1 = one.foo;
        #     var foo2 = two.foo;
        #     foo1 === foo2; // expect 'same' reference
        #     foo1(); foo2(); // one ref but different implicit 'this' objects
        #
        # returns different instances as obj1.method(:foo) != obj2.method(:foo)
        #
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

      def unwrap
        @callable
      end
      
      # override int BaseFunction#getLength()
      def getLength
        arity = @callable.arity
        arity < 0 ? 0 : arity  # -1 for `lambda { 42 }`
      end

      # #deprecated int BaseFunction#getArity()
      def getArity
        getLength
      end

      # override String BaseFunction#getFunctionName()
      def getFunctionName
        @callable.is_a?(Proc) ? "" : @callable.name
      end

      # protected Object ScriptableObject#equivalentValues(Object value)
      def equivalentValues(other) # JS == operator
        return false unless other.is_a?(Function)
        return true if unwrap == other.unwrap
        # Method.== does check if their bind to the same object
        # JS == means they might be bind to different objects :
        unwrap.to_s == other.unwrap.to_s # "#<Method: Foo#bar>"
      end

      # override Object BaseFunction#call(Context context, Scriptable scope, 
      #                                   Scriptable thisObj, Object[] args)
      def call(context, scope, this, args)
        args = args.to_a # java.lang.Object[] -> Array
        # JS function style :
        if (arity = @callable.arity) >= 0
          if args.size > arity # omit 'redundant' arguments
            args = args.slice(0, arity)
          elsif arity > args.size # fill 'missing' arguments
            (arity - args.size).times { args.push(nil) }
          end
        end
        rb_args = Rhino.args_to_ruby(args)
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

      # override int BaseFunction#getLength()
      def getLength
        arity = @klass.instance_method(:initialize).arity
        arity < 0 ? 0 : arity  # -1 for `initialize(*args)`
      end
      
      # override boolean Scriptable#hasInstance(Scriptable instance);
      def hasInstance(instance)
        return false unless instance
        return true if instance.is_a?(@klass)
        instance.is_a?(Object) && instance.unwrap.is_a?(@klass)
      end

    end

    def self.cache(key)
      fetch(key) || store(key, yield)
    end
    
    private
    
      # NOTE: just to get === comparison's working ...
      # if == is enough might be disabled by setting to nil
      @@cache = java.util.WeakHashMap.new
    
      def self.fetch(key)
        ref = @@cache && @@cache.get(key)
        ref ? ref.get : nil
      end

      def self.store(key, value)
        @@cache.put(key, java.lang.ref.WeakReference.new(value)) if @@cache
        value
      end
    
  end
  
  RubyObject = Ruby::Object
  RubyFunction = Ruby::Function
  RubyConstructor = Ruby::Constructor
  
end
