require File.dirname(__FILE__) + '/../spec_helper'

include Rhino
  
describe Rhino::Context do  
  
  it "can evaluate some javascript" do
    Context.open do |cxt|
      cxt.eval("5 + 3").should == 8
    end
  end
  
  it "treats nil and the empty string as the same thing when it comes to eval" do
    Context.open do |cxt|
      cxt.eval(nil).should == cxt.eval('')
    end
  end
  
  it "can embed primitive ruby object into javascript" do
    Context.open do |cxt|
      cxt['foo'] = "Hello World"
      cxt.eval("foo").should == "Hello World"
    end
  end  
  
  describe "Initalizing Standard Javascript Objects" do
    it "provides the standard objects without java integration by default" do
      Context.open do |cxt|
        cxt["Object"].should_not be_nil
        cxt["Math"].should_not be_nil
        cxt["String"].should_not be_nil
        cxt["Function"].should_not be_nil
        cxt["Packages"].should be_nil
        cxt["java"].should be_nil
        cxt["org"].should be_nil
        cxt["com"].should be_nil
      end
    end
    
    it "provides unsealed standard object by default" do
      Context.open do |cxt|
        cxt.eval("Object.foop = 'blort'")
        cxt["Object"]['foop'].should == 'blort'
      end
    end
    
    it "allows you to seal the standard objects so that they cannot be modified" do
      Context.open(:sealed => true) do |cxt|
        lambda {
          cxt.eval("Object.foop = 'blort'")            
        }.should raise_error(Rhino::RhinoError)
        
        lambda {
          cxt.eval("Object.prototype.toString = function() {}")            
        }.should raise_error(Rhino::RhinoError)          
      end
    end
    
    it "allows java integration to be turned on when initializing standard objects" do
      Context.open(:java => true) do |cxt|
          cxt["Packages"].should_not be_nil
      end
    end    
  end
  
  
  it "can call ruby functions from javascript" do
    Context.open do |cxt|
      cxt["say"] = lambda {|word, times| word * times}
      cxt.eval("say('Hello',2)").should == "HelloHello"
    end
  end
  
  it "can limit the number of instructions that are executed in the context" do
    lambda {
      Context.open do |cxt|
        cxt.instruction_limit = 100 * 1000
        timeout(1) do
          cxt.eval('while (true);')
        end
      end
    }.should raise_error(Rhino::RunawayScriptError)
  end
    
  it "has a private constructor" do
    lambda {
      Context.new(nil)
    }.should raise_error
  end
end