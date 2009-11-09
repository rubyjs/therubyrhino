
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
      @prototype ||= J::NativeObject.new.tap do |p|
        p.put("toString", p, Function.new {to_s})
        for name in @ruby.public_methods(false).reject {|m| m == 'initialize'}
          method = @ruby.method(name)                    
          p.put(name.gsub(/_(\w)/) {$1.upcase}, p, Function.new(method) {})
        end
      end
    end
    
    def to_s
      "[Native #{@ruby.class.name}]"
    end
    
    alias_method :prototype, :getPrototype
  end
end