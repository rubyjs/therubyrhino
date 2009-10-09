require File.dirname(__FILE__) + '/../spec_helper'

include Rhino
  
describe Rhino::Context do  
  
  it "can evaluate some javascript" do
    Context.open do |cxt|
      cxt.evaljs("5 + 3").should == 8
    end
  end
  
  it "can embed primitive ruby object into javascript" do
    Context.open do |cxt|
      cxt.init_standard_objects.tap do |scope|
        scope["foo"] = "Hello World"
        cxt.evaljs("foo", scope).should == "Hello World"
      end
    end
  end  
  
  describe "Initalizing Standard Javascript Objects" do
    it "provides the standard objects without java integration by default" do
      Context.open do |cxt|
        cxt.init_standard_objects.tap do |scope|
          scope["Object"].should_not be_nil
          scope["Math"].should_not be_nil
          scope["String"].should_not be_nil
          scope["Function"].should_not be_nil
          scope["Packages"].should be_nil
          scope["java"].should be_nil
          scope["org"].should be_nil
          scope["com"].should be_nil
        end
      end
    end
    
    it "provides unsealed standard object by default" do
      Context.open do |cxt|
        cxt.init_standard_objects.tap do |scope|
          cxt.evaljs("Object.foop = 'blort'", scope)
          scope["Object"]['foop'].should == 'blort'
        end
      end
    end
    
    it "allows you to seal the standard objects so that they cannot be modified" do
      Context.open do |cxt|
        cxt.init_standard_objects(:sealed => true).tap do |scope|
          lambda {
            cxt.evaljs("Object.foop = 'blort'", scope)            
          }.should raise_error(Rhino::RhinoError)
          
          lambda {
            cxt.evaljs("Object.prototype.toString = function() {}", scope)            
          }.should raise_error(Rhino::RhinoError)
          
        end
      end
    end
    
    it "allows java integration to be turned on when initializing standard objects" do
      Context.open do |cxt|
        cxt.init_standard_objects(:java => true).tap do |scope|
          scope["Packages"].should_not be_nil
        end
      end
    end
    
    it "provides a convenience method for initializing scopes" do
      Context.open_std(:sealed => true, :java => true) do |cxt, scope|
        scope["Object"].should_not be_nil
        scope["java"].should_not be_nil
        cxt.evaljs("new java.lang.String('foo')", scope).should == "foo"
      end
    end    
  end
  
  
  it "can call ruby functions from javascript" do
    Context.open do |cxt|
      cxt.standard do |scope|
        scope.put("say", scope, function {|word, times| word * times})
        cxt.evaljs("say('Hello',2)", scope).should == "HelloHello"
      end
    end
  end
    
  it "has a private constructor" do
    lambda {
      Context.new(nil)
    }.should raise_error
  end
end