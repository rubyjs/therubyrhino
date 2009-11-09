
module Rhino
  module To        
    JS_UNDEF = [J::Scriptable::NOT_FOUND, J::Undefined]
    
    def ruby(object)
      case object
      when *JS_UNDEF          then nil
      when Rhino::RubyObject  then object
      when J::Wrapper         then object.unwrap
      when J::Scriptable      then NativeObject.new(object)
      else  object
      end        
    end
    
    def javascript(object)
      case object
      when NativeObject then object.j
      when J::Scriptable then object
      else RubyObject.new(object)
      end
    end
    
    module_function :ruby, :javascript    
  end
end
