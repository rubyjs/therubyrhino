
module Rhino
  # Wraps a javascript object and makes its properties available from ruby.
  class NativeObject
    include Enumerable
    
    # The native java object wrapped by this NativeObject. This will generally
    # be an instance of org.mozilla.javascript.Scriptable
    attr_reader :j
    
    def initialize(j=nil) # :nodoc:
      @j = j || JS::NativeObject.new
    end
    
    # get a property from this javascript object, where +k+ is a string or symbol
    # corresponding to the property name
    # e.g.
    #   jsobject = Context.open do |cxt|
    #      cxt.eval('({foo: 'bar',  'Take me to': 'a funky town'})')
    #   end
    # 
    #   jsobject[:foo] # => 'bar'
    #   jsobject['foo'] # => 'bar'
    #   jsobject['Take me to'] # => 'a funky town'
    def [](k)
      To.ruby JS::ScriptableObject.getProperty(@j,k.to_s)
    end
    
    # set a property on the javascript object, where +k+ is a string or symbol corresponding
    # to the property name, and +v+ is the value to set. e.g.
    #
    #   jsobject = eval_js "new Object()"
    #   jsobject['foo'] = 'bar'
    #   Context.open(:with => jsobject) do |cxt|
    #     cxt.eval('foo') # => 'bar'
    #   end

    def []=(k,v)
      JS::ScriptableObject.putProperty(@j, k.to_s, To.javascript(v))
    end
    
    # enumerate the key value pairs contained in this javascript object. e.g.
    # 
    #   eval_js("{foo: 'bar', baz: 'bang'}").each do |key,value|
    #     puts "#{key} -> #{value} "
    #   end
    #
    # outputs foo -> bar baz -> bang
    def each
      for id in @j.getAllIds() do
        yield id,@j.get(id,@j)
      end
    end
    
    # Converts the native object to a hash. This isn't really a stretch since it's
    # pretty much a hash in the first place.
    def to_h
      {}.tap do |h|
        each do |k,v|
          v = To.ruby(v)
          h[k] = self.class === v ? v.to_h : v
        end
      end
    end
    
    # Convert this javascript object into a json string.
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end