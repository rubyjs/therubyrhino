
module Rhino
  module To
    JS_UNDEF = [JS::Scriptable::NOT_FOUND, JS::Undefined]

    module_function

    def ruby(object)
      case object
      when *JS_UNDEF                then nil
      when JS::Wrapper               then object.unwrap
      when JS::NativeArray           then array(object)
      when JS::NativeDate            then Time.at(object.getJSTimeValue() / 1000)
      when JS::Regexp::NativeRegExp  then object
      when JS::Function              then j2r(object) {|o| NativeFunction.new(o)}
      when JS::Scriptable            then j2r(object) {|o| NativeObject.new(o)}
      else  object
      end
    end

    def javascript(object)
      case object
      when String,Numeric       then object
      when TrueClass,FalseClass then object
      when Array                then JS::NativeArray.new(object.to_java)
      when Hash                 then ruby_hash_to_native(object)
      when Proc,Method          then r2j(object, object.to_s) {|o| RubyFunction.new(o)}
      when NativeObject         then object.j
      when JS::Scriptable        then object
      else r2j(object) {|o| RubyObject.new(o)}
      end
    end

    def array(native)
      native.length.times.map {|i| ruby(native.get(i,native))}
    end

    def ruby_hash_to_native(ruby_object)
      native_object = NativeObject.new

      ruby_object.each_pair do |k, v|
        native_object[k] = v
      end

      native_object.j
		end

    @@j2r = {}
		def j2r(value)
		  key = value.object_id
      if ref = @@j2r[key]
        if peer = ref.get()
          return peer
        else
          @@j2r.delete(key)
          return j2r(value) {|o| yield o}
        end
      else
        yield(value).tap do |peer|
          @@j2r[key] = java.lang.ref.WeakReference.new(peer)
        end
      end
    end

    @@r2j = {}
    def r2j(value, key = value.object_id)
      if ref = @@r2j[key]
        if peer = ref.get()
          return peer
        else
          @@r2j.delete(key)
          return r2j(value, key) {|o| yield o}
        end
      else
        yield(value).tap do |peer|
          @@r2j[key] = java.lang.ref.WeakReference.new(peer)
        end
      end
    end
  end
end
