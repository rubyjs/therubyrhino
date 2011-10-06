
module Rhino
  module To
    JS_UNDEF = [J::Scriptable::NOT_FOUND, J::Undefined]

    module_function

    def ruby(object)
      case object
      when *JS_UNDEF                then nil
      when J::Wrapper               then object.unwrap
      when J::NativeArray           then array(object)
      when J::NativeDate            then Time.at(object.getJSTimeValue() / 1000)
      when J::Regexp::NativeRegExp  then object
      when J::Function              then r2j(object) {|o| NativeFunction.new(o)}
      when J::Scriptable            then r2j(object) {|o| NativeObject.new(o)}
      else  object
      end
    end

    def javascript(object)
      case object
      when String,Numeric       then object
      when TrueClass,FalseClass then object
      when Array                then J::NativeArray.new(object.to_java)
      when Hash                 then ruby_hash_to_native(object)
      when Proc,Method          then RubyFunction.new(object)
      when NativeObject         then object.j
      when J::Scriptable        then object
      else RubyObject.new(object)
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

    @@r2j = {}

		def r2j(value)
      if ref = @@r2j[value.object_id]
        if peer = ref.get()
          return peer
        end
      else
        yield(value).tap do |peer|
          @@r2j[value.object_id] = java.lang.ref.WeakReference.new(peer)
        end
      end
    end

  end
end
