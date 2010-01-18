
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
    
    def getIds()
      puts "getIds()"
      require 'java'
      @ruby.public_methods(false).map {|m| m.gsub(/(.)_(.)/) {::JavaLang::String.new("#{$1}#{$2.upcase}")}}.tap {|ids| puts "ids: #{ids.inspect}"}.to_java
    end
        
    def to_s
      "[Native #{@ruby.class.name}]"
    end
    
    alias_method :prototype, :getPrototype
    
    
    class Prototype < J::ScriptableObject
            
      def get(name, start)
        robject = To.ruby(start)
        if name == "toString" 
          return RubyFunction.new(lambda { "[Ruby #{robject.class.name}]"})
        end
        rb_name = name.gsub(/([a-z])([A-Z])/) {"#{$1}_#{$2.downcase}"}
        if (robject.public_methods(false).include?(rb_name)) 
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
        rb_name = name.gsub(/([a-z])([A-Z])/) {"#{$1}_#{$2.downcase}"}
        To.ruby(start).public_methods(false).respond_to?(rb_name) ? true : super(name,start)
      end
                  
      Generic = new
      
    end
  end
end