
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
  
  describe Enumerable do
    it "enumerates according to native keys and values" do
      @j.put("foo", @j, 'bar')
      @j.put("bang", @j, 'baz')
      @j.put(5, @j, 'flip')
      @o.inject({}) {|i,p| k,v = p; i.tap {i[k] = v}}.should == {"foo" => 'bar', "bang" => 'baz', 5 => 'flip'}
    end
  end
  
end
