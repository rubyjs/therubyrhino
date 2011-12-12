require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Rhino::RubyFunction do
  
  it "create and unwrap ruby function" do
    rb_function = Rhino::RubyFunction.wrap method = Object.new.method(:to_s)
    rb_function.unwrap.should be(method)
  end

  it "call a ruby function" do
    rb_function = Rhino::RubyFunction.wrap method = 'foo'.method(:to_s)
    context = nil; scope = nil; this = nil; args = nil
    rb_function.call(context, scope, this, args).should == 'foo'
  end

  it "args get converted before delegating a ruby function call" do
    klass = Class.new(Object) do
      def foo(array)
        array.all? { |elem| elem.is_a?(String) }
      end
    end
    rb_function = Rhino::RubyFunction.wrap method = klass.new.method(:foo)
    context = nil; scope = nil; this = nil
    args = [ '1'.to_java, java.lang.String.new('2') ].to_java
    args = [ Rhino::JS::NativeArray.new(args) ].to_java
    rb_function.call(context, scope, this, args).should be(true)
  end

  it "returned value gets converted to javascript" do
    klass = Class.new(Object) do
      def foo
        [ 42 ]
      end
    end
    rb_function = Rhino::RubyFunction.wrap method = klass.new.method(:foo)
    context = nil; scope = nil; this = nil; args = [].to_java
    rb_function.call(context, scope, this, args).should be_a(Rhino::JS::NativeArray)
  end
  
end