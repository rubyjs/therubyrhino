
module Rhino
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