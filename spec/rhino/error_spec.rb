require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Rhino::JSError do
  
  it "works as a StandardError with a message being passed" do
    js_error = Rhino::JSError.new 'an error message'
    lambda { js_error.to_s && js_error.inspect }.should_not raise_error
    
    js_error.cause.should be nil
    js_error.message.should == 'an error message'
    js_error.javascript_backtrace.should be nil
  end
  
  it "might wrap a RhinoException wrapped in a NativeException like error" do
    # JRuby's NativeException.new(rhino_e) does not work as it is
    # intended to handle Java exceptions ... no new on the Ruby side
    native_error_class = Class.new(RuntimeError) do
      
      def initialize(cause)
        @cause = cause
      end
      
      def cause
        @cause
      end
      
    end
    
    rhino_e = Rhino::JS::JavaScriptException.new("42".to_java)
    js_error = Rhino::JSError.new native_error_class.new(rhino_e)
    lambda { js_error.to_s && js_error.inspect }.should_not raise_error
    
    js_error.cause.should be rhino_e
    js_error.message.should == '42'
    js_error.javascript_backtrace.should_not be nil
  end
  
  it "keeps the thrown javascript object value" do
    begin
      Rhino::Context.eval "throw { foo: 'bar' }"
    rescue => e
      e.should be_a(Rhino::JSError)
      e.value.should be_a(Rhino::JS::NativeObject)
      e.value['foo'].should == 'bar'
      e.value.should == e.message
    else
      fail "expected to rescue"
    end
  end

  it "keeps the thrown javascript string value" do
    begin
      Rhino::Context.eval "throw 'mehehehe'"
    rescue => e
      e.should be_a(Rhino::JSError)
      e.value.should == 'mehehehe'
      e.value.should == e.message
    else
      fail "expected to rescue"
    end
  end
  
end