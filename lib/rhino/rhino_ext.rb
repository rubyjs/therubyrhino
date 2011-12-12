
# The base class for all JavaScript objects.
class Java::OrgMozillaJavascript::ScriptableObject
  
  import "org.mozilla.javascript"
  
  # get a property from this javascript object, where +k+ is a string or symbol
  # corresponding to the property name e.g.
  # 
  #     jsobject = Context.open do |cxt|
  #       cxt.eval('({foo: 'bar', 'Take me to': 'a funky town'})')
  #     end
  #     jsobject[:foo] # => 'bar'
  #     jsobject['foo'] # => 'bar'
  #     jsobject['Take me to'] # => 'a funky town'
  #
  def [](name)
    Rhino.to_ruby ScriptableObject.getProperty(self, name.to_s)
  end

  # set a property on the javascript object, where +k+ is a string or symbol corresponding
  # to the property name, and +v+ is the value to set. e.g.
  #
  #     jsobject = eval_js "new Object()"
  #     jsobject['foo'] = 'bar'
  #     Context.open(:with => jsobject) do |cxt|
  #       cxt.eval('foo') # => 'bar'
  #     end
  #
  def []=(key, value)
    scope = self
    ScriptableObject.putProperty(self, key.to_s, Rhino.to_javascript(value, scope))
  end
  
  # enumerate the key value pairs contained in this javascript object. e.g.
  #
  #     eval_js("{foo: 'bar', baz: 'bang'}").each do |key,value|
  #       puts "#{key} -> #{value} "
  #     end
  #
  # outputs foo -> bar baz -> bang
  #
  def each
    each_raw { |key, val| yield key, Rhino.to_ruby(val) }
  end
  
  def each_key
    each_raw { |key, val| yield key }
  end

  def each_value
    each_raw { |key, val| yield Rhino.to_ruby(val) }
  end
  
  def each_raw
    for id in getAllIds do
      yield id, get(id, self)
    end
  end
  
  def keys
    keys = []
    each_key { |key| keys << key }
    keys
  end
  
  def values
    vals = []
    each_value { |val| vals << val }
    vals    
  end
  
  # Converts the native object to a hash. This isn't really a stretch since it's
  # pretty much a hash in the first place.
  def to_h
    hash = {}
    each do |key, val|
      hash[key] = val.is_a?(ScriptableObject) ? val.to_h : val
    end
    hash
  end

  # Convert this javascript object into a json string.
  def to_json(*args)
    to_h.to_json(*args)
  end
  
  # Delegate methods to JS object if possible when called from Ruby.
  def method_missing(name, *args)
    s_name = name.to_s
    if s_name[-1, 1] == '=' && args.size == 1 # writer -> JS put
      self[ s_name[0...-1] ] =  args[0]
    else
      property = ScriptableObject.getProperty(self, s_name)
      if property && property != Scriptable::NOT_FOUND
        if property.is_a?(Rhino::JS::Function)
          begin
            context = Rhino::JS::Context.enter
            js_args = Rhino.args_to_javascript(args, self) # scope == self
            Rhino.to_ruby property.call(context, self, s_name, js_args)
          ensure
            Rhino::JS::Context.exit
          end
        else
          if args.size > 0
            raise ArgumentError, "can't #{name}(#{args.join(', ')}) as '#{name}' is a property"
          end
          Rhino.to_ruby property
        end
      else
        super
      end
    end
  end
  
end

class Java::OrgMozillaJavascript::NativeObject
  
  import "org.mozilla.javascript"
  
  def [](name)
    value = Rhino.to_ruby(ScriptableObject.getProperty(self, s_name = name.to_s))
    # handle { '5': 5 }.keys() ... [ 5 ] not [ '5' ] !
    if value.nil? && (i_name = s_name.to_i) != 0
      value = Rhino.to_ruby(ScriptableObject.getProperty(self, i_name))
    end
    value
  end
  
  # re-implement unsupported Map#put
  def []=(key, value)
    scope = self
    ScriptableObject.putProperty(self, key.to_s, Rhino.to_javascript(value, scope))
  end
  
end

# The base class for all JavaScript function objects.
class Java::OrgMozillaJavascript::BaseFunction
  
  alias_method :__call__, :call # Rhino's Function#call(a1, a2, a3, a4)
  
  # make JavaScript functions callable Ruby style e.g. `fn.call('42')`
  def call(*args)
    context = Rhino::JS::Context.enter
    scope = getParentScope || context.initStandardObjects
    __call__(context, scope, scope, Rhino.args_to_javascript(args, scope))
  ensure
    Rhino::JS::Context.exit
  end
  
  # use JavaScript functions constructors from Ruby as `fn.new`
  def new(*args)
    context = Rhino::JS::Context.enter
    scope = getParentScope || context.initStandardObjects
    construct(context, scope, Rhino.args_to_javascript(args, scope))
  ensure
    Rhino::JS::Context.exit
  end
  
end
