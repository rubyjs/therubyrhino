require File.dirname(__FILE__) + '/../spec_helper'

include Rhino
  
describe Rhino::Context do  
  
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
    
    it "allows you to scope the context to an object" do
      class MyScope
        def foo; proc { 'bar' }; end
      end
      Context.open(:with => MyScope.new) do |ctx|
        ctx.eval("foo()").should == 'bar'
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
end