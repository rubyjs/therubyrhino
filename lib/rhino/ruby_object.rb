
module Rhino
  class RubyObject < JS::ScriptableObject
    include JS::Wrapper

    def initialize(object)
      super()
      @ruby = object
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
        # NOTE: preferrably when using a ruby object in JS methods should
        # be used but instance variables will work as well but if there's
        # a attr reader it is given a preference e.g. :
        #
        #     class Foo
        #       attr_reader :bar2
        #       def initialize
        #         @bar1 = 'bar1'
        #         @bar2 = 'bar2'
        #       end
        #     end
        #     
        #     fooObj.bar1; // 'bar1'
        #     fooObj.bar2; // function
        #     fooObj.bar2(); // 'bar2'
        #
        if @ruby.respond_to?(name)
          return RubyFunction.new(@ruby.method(name))
        elsif @ruby.instance_variables.include?(var_name = "@#{name}")
          var_value = @ruby.instance_variable_get(var_name)
          return Rhino::To.to_javascript(var_value, self)
        end
      end
      super
    end

    # override boolean Scriptable#has(String name, Scriptable start);
    # override boolean Scriptable#has(int index, Scriptable start);
    def has(name, start)
      if name.is_a?(String) 
        if @ruby.respond_to?(name) || 
           @ruby.instance_variables.include?("@#{name}")
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
          return @ruby.send(set_name, Rhino::To.to_ruby(value))
        end
      end
      super
    end
    
    # override boolean Scriptable#hasInstance(Scriptable instance);
    def hasInstance(instance)
      super
    end
    
    # override Object[] Scriptable#getIds();
    def getIds
      ids = @ruby.instance_variables.map { |ivar| ivar[1..-1].to_java }
      @ruby.public_methods(false).each do |name| 
        name = name[0...-1] if name[-1, 1] == '=' # 'foo=' ... 'foo'
        name = name.to_java
        ids << name unless ids.include?(name)
      end
      super.each { |id| ids.unshift(id) }
      ids.to_java
    end
    
  end
end
