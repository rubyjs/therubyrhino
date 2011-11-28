
module Rhino
  class RubyObject < J::ScriptableObject
    include J::Wrapper

    def initialize(object)
      super()
      @ruby = object
    end

    def unwrap
      @ruby
    end

    def getClassName()
      @ruby.class.name
    end

    def getPrototype()
      Prototype::Generic
    end

    def put(key, start, value)
      if accessible_methods(true).include?(:"#{key}=")
        @ruby.send("#{key}=", To.ruby(value))
        value
      else
        super
      end
    end

    def getIds()
      accessible_methods.map {|m| m.to_s.gsub(/(.)_(.)/) {java.lang.String.new("#{$1}#{$2.upcase}")}}.to_java
    end

    def to_s
      "[Native #{@ruby.class.name}]"
    end

    alias_method :prototype, :getPrototype

    protected

    def accessible_methods(special_methods = false)
      self.class.accessible_methods(@ruby, special_methods)
    end

    def self.accessible_methods(obj, special_methods = false)
      obj.public_methods(false).collect(&:to_sym).to_set.tap do |methods|
        ancestors = obj.class.ancestors.dup
        while ancestor = ancestors.shift
          break if ancestor == ::Object
          methods.merge(ancestor.public_instance_methods(false).collect(&:to_sym))
        end
        methods.reject! {|m| m == :[] || m == :[]= || m.to_s =~ /=$/} unless special_methods
      end
    end

    class Prototype < J::ScriptableObject

      def get(name, start)
        robject = To.ruby(start)
        if name == "toString"
          return RubyFunction.new(lambda { "[Ruby #{robject.class.name}]"})
        end
        rb_name = name.gsub(/([a-z])([A-Z])/) {"#{$1}_#{$2.downcase}"}.to_sym
        if (RubyObject.accessible_methods(robject).include?(rb_name))
          method = robject.method(rb_name)
          if method.arity == 0
            To.javascript(method.call)
          else
            RubyFunction.new(method)
          end
        else
          super(name, start)
        end
      end

      def has(name, start)
        rb_name = name.gsub(/([a-z])([A-Z])/) {"#{$1}_#{$2.downcase}"}.to_sym
        robject = To.ruby(start)
        RubyObject.accessible_methods(robject).include?(rb_name) || super(name,start)
      end

      Generic = new
    end
  end
end
