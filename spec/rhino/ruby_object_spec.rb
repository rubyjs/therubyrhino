require File.dirname(__FILE__) + '/../spec_helper'

describe Rhino::RubyObject do
  
  before(:each) do
    @class = Class.new
    @instance = @class.new
  end
  
  it "can call public locally defined ruby methods" do
    class_eval do
      def voo
        "doo"
      end
    end
    eval("o.voo").should_not be_nil
    eval("o.voo()").should == "doo"
  end
  
  it "translates ruby naming conventions into javascript naming conventions, but you can still access them by their original names" do
    class_eval do
      def my_special_method
        "hello"
      end
    end
    eval("o.mySpecialMethod").should_not be_nil
    eval("o.mySpecialMethod()").should == "hello"
    eval("o.my_special_method").should_not be_nil
    eval("o.my_special_method()").should == "hello"
  end
  
  it "hides methods not defined directly on this instance's class" do
    class_eval do
      def bar
      end
    end
    eval("o.to_s").should be_nil
  end
  
  it "translated camel case properties are enumerated by default, but perl case are not"
  
  it "will see a method that appears after the wrapper was first created" do
    Rhino::Context.open do |cxt|
      cxt['o'] = @instance
      class_eval do
        def bar
          "baz!"
        end
      end
      cxt.eval("o.bar").should_not be_nil
      cxt.eval("o.bar()").should == "baz!"
    end
  end
  
  it "allows you to specify which methods should be treated as properties"
  
  
  def eval(str)
    Rhino::Context.open do |cxt|
      cxt['o'] = @instance
      cxt.eval(str)
    end
  end
  
  def class_eval(&body)
    @class.class_eval &body
  end
end
