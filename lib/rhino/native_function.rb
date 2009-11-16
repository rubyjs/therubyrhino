
module Rhino
  
  # Wraps a function that has been defined in Javascript so that it can 
  # be referenced and called from javascript. e.g.
  #
  #   plus = Rhino::Context.open do |cx|
  #     cx.eval('function(lhs, rhs) {return lhs + rhs}')
  #   end
  #   plus.call(5,4) # => 9
  #
  class NativeFunction < NativeObject    
    def call(*args)
      begin        
        cxt = J::Context.enter()
        scope = @j.getParentScope() || cxt.initStandardObjects()
        @j.call(cxt, scope, scope, args.map {|o| To.javascript(o)})
      ensure
        J::Context.exit()
      end
    end
  end
end