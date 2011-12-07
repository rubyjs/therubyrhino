
module Rhino
  class RubyObject < JS::ScriptableObject
    include JS::Wrapper

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
      if @ruby.respond_to?("#{key}=")
        @ruby.send("#{key}=", To.ruby(value))
        value
      else
        super
      end
    end

    def getIds()
      @ruby.public_methods(false).map {|m| m.gsub(/(.)_(.)/) {java.lang.String.new("#{$1}#{$2.upcase}")}}.to_java
    end

    def to_s
      "[Native #{@ruby.class.name}]"
    end

    alias_method :prototype, :getPrototype


    class Prototype < JS::ScriptableObject

      def get(name, start)
        robject = To.ruby(start)
        if name == "toString"
          return RubyFunction.new(lambda { "[Ruby #{robject.class.name}]"})
        end
        rb_name = name.gsub(/([a-z])([A-Z])/) {"#{$1}_#{$2.downcase}"}.to_sym
        if (robject.public_methods(false).collect(&:to_sym).include?(rb_name))
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
        To.ruby(start).public_methods(false).collect(&:to_sym).include?(rb_name) ? true : super(name,start)
      end

      Generic = new
    end
  end
end
