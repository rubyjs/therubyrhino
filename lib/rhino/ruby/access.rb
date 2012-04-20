module Rhino
  module Ruby
    
    autoload :DefaultAccess, "rhino/ruby/default_access"
    autoload :AttributeAccess, "rhino/ruby/attribute_access"
    
    class AccessBase
      
      def has(object, name, scope)
        # try [](name) method :
        if object.respond_to?(:'[]') && object.method(:'[]').arity == 1
          return true unless object[name].nil?
        end
        yield
      end
      
      def get(object, name, scope)
        # try [](name) method :
        if object.respond_to?(:'[]') && object.method(:'[]').arity == 1
          unless (value = object[name]).nil?
            return Rhino.to_javascript(value, scope)
          end
        end
        yield
      end
      
      def put(object, name, value)
        # try []=(name, value) method :
        if object.respond_to?(:'[]=') && object.method(:'[]=').arity == 2
          return object[name] = Rhino.to_ruby(value)
        end
        yield
      end
      
    end
    
    module DeprecatedAccess
      
      def has(object, name, scope, &block)
        Rhino.warn "[DEPRECATION] `#{self.name}.has` is deprecated, please sub-class #{self.name} instead."
        instance.has(object, name, scope, &block)
      end

      def get(object, name, scope, &block)
        Rhino.warn "[DEPRECATION] `#{self.name}.get` is deprecated, please sub-class #{self.name} instead."
        instance.get(object, name, scope, &block)
      end

      def put(object, name, value, &block)
        Rhino.warn "[DEPRECATION] `#{self.name}.put` is deprecated, please sub-class #{self.name} instead."
        instance.put(object, name, value, &block)
      end

      private
      def instance
        @instance ||= self.new
      end
      
    end
    
  end
end