
module Rhino
  class NativeObject
    attr_reader :j
    def initialize(j)
      @j = j
    end
    
    def [](k)
      if v = @j.get(k.to_s,@j)
        v == J::Scriptable::NOT_FOUND ? nil : Context.to_ruby(v)
      end
    end
    
    def []=(k,v)
      @j.put(k.to_s,@j,v)
    end
  end
end