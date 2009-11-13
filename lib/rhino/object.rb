
class Object
  def eval_js(source, options = {})
    Rhino::Context.open(options.merge(:with => self)) do |cxt|
      cxt.eval(source)
    end
  end
end