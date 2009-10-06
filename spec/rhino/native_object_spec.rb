
require File.dirname(__FILE__) + '/../spec_helper'

include Rhino

describe Rhino::NativeObject do
  
  before(:each) do
    @j = J::NativeObject.new
    @o = NativeObject.new(@j)
  end
  
  it "wraps a native javascript object" do
    @o["foo"] = 'bar'
    @j.get("foo", @j).should == "bar"    
    @j.put("blue",@j, "blam")
    @o["blue"].should == "blam"
  end
  
  it "doesn't matter if you use a symbol or a string to set a value" do
    @o[:foo] = "bar"
    @o['foo'].should == "bar"
    @o['baz'] = "bang"
    @o[:baz].should == "bang"
  end
  
  it "returns nil when the value is null, null, or not defined" do
    @o[:foo].should be_nil
  end
  
end
