require File.dirname(__FILE__) + '/../spec_helper'

include Rhino

describe Rhino::To do
  describe "ruby translation" do
    it "converts javascript NOT_FOUND to ruby nil" do
      To.ruby(J::Scriptable::NOT_FOUND).should be_nil
    end
  
    it "wraps native javascript objects in a ruby NativeObject wrapper" do
      J::NativeObject.new.tap do |o|
        To.ruby(o).tap do |ruby_object|
          ruby_object.should respond_to(:j)
          ruby_object.j.should be(o)
        end
      end
    end
    
    it "leaves native ruby objects alone" do
      Object.new.tap do |o|
        To.ruby(o).should be(o)
      end
    end
    
    it "it unwraps wrapped java objects" do
      Context.open do |cx|
        scope = cx.init_standard_objects
        Java::JavaLang::String.new("Hello World").tap do |str|
          J::NativeJavaObject.new(scope.j, str, str.getClass()).tap do |o|
            To.ruby(o).should == "Hello World"
          end
        end
      end
    end
  end
  
  describe  "javascript translation" do
    it "unwraps wrapped ruby objects before passing them to the javascript runtime" do
      J::NativeObject.new.tap do |o|
        To.javascript(NativeObject.new(o)).should be(o)
      end        
    end
    
    it "leaves native javascript objects alone" do
      J::NativeObject.new.tap do |o|
        To.javascript(o).should be(o)
      end
    end
    
  end
end