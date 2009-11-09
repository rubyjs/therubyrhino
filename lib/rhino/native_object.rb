
module Rhino
  class NativeObject
    include Enumerable
    attr_reader :j
    
    def initialize(j)
      @j = j
    end
    
    def [](k)
      To.ruby @j.get(k.to_s, @j)
    end
    
    def []=(k,v)
      @j.put(k.to_s,@j,To.javascript(v))
    end
    
    def each
      for id in @j.getAllIds() do
        yield id,@j.get(id,@j)
      end
    end
    
    def to_h
      {}.tap do |h|
        each do |k,v|
          h[k] = self.class === v ? v.to_h : v
        end
      end
    end
    
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end