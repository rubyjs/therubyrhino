
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
      cxt = JS::Context.enter()
      scope = @j.getParentScope() || cxt.initStandardObjects()
      @j.call(cxt, scope, scope, args.map {|o| To.javascript(o)})
    ensure
      JS::Context.exit()
    end

    def methodcall(this, *args)
      cxt = JS::Context.enter()
      scope = @j.getParentScope() || cxt.initStandardObjects()
      @j.call(cxt, scope, To.javascript(this), args.map {|o| To.javascript(o)})
    ensure
      JS::Context.exit()
    end
  end
end