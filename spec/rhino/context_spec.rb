require File.dirname(__FILE__) + '/../spec_helper'

describe Rhino::Context do  
  include Rhino
  
  it "can evaluate some javascript" do
    Rhino::Context.open do |cxt|
      cxt.evaljs("5 + 3").should == 8
    end
  end
  
  it "can embed ruby object into javascript" do
    Rhino::Context.open do |cxt|
      cxt.standard do |scope|
        scope.put("foo", scope, "Hello World")
        cxt.evaljs("foo", scope).should == "Hello World"
      end
    end
  end
  
  it "can call ruby functions from javascript" do
    Rhino::Context.open do |cxt|
      cxt.standard do |scope|
        scope.put("say", scope, function {|word, times| word * times})
        cxt.evaljs("say('Hello',2)", scope).should == "HelloHello"
      end
    end
  end
    
  it "has a private constructor" do
    lambda {
      Rhino::Context.new(nil)
    }.should raise_error
  end
  
end