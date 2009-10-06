
module Rhino
  class NativeObject
    include Enumerable
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
    
    def each
      for id in @j.getAllIds() do
        yield id,@j.get(id,@j)
      end
    end
  end
end