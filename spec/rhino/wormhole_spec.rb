require File.dirname(__FILE__) + '/../spec_helper'

describe Rhino::To do
  describe "ruby translation" do
    it "converts javascript NOT_FOUND to ruby nil" do
      Rhino::To.ruby(Rhino::JS::Scriptable::NOT_FOUND).should be_nil
    end
  
    it "converts javascript arrays to ruby arrays" do
      Rhino::JS::NativeObject.new.tap do |o|
        Rhino::To.ruby(o).tap do |ruby_object|
          ruby_object.should respond_to(:j)
          ruby_object.j.should be(o)
        end
      end
    end
    
    it "wraps native javascript arrays into a ruby NativeArray wrapper" do
      Rhino::JS::NativeArray.new([1,2,4].to_java).tap do |a|
        Rhino::To.ruby(a).should == [1,2,4]
      end
    end
    
    it "wraps native javascript functions into a ruby NativeFunction wrapper" do
      
      c = Class.new(Rhino::JS::BaseFunction).class_eval do
        self.tap do
          def call(cxt, scope, this, args)
            args.join(',')
          end
        end
      end
      
      c.new.tap do |f|
        Rhino::To.ruby(f).tap do |o|
          o.should_not be_nil
          o.should be_kind_of(Rhino::NativeObject)
          o.should be_respond_to(:call)
          o.call(1,2,3).should == "1,2,3"
        end
      end
      
    end
    
    it "leaves native ruby objects alone" do
      Object.new.tap do |o|
        Rhino::To.ruby(o).should be(o)
      end
    end
    
    it "it unwraps wrapped java objects" do
      Rhino::Context.open do |cx|
        scope = cx.scope
        java.lang.String.new("Hello World").tap do |str|
          Rhino::JS::NativeJavaObject.new(scope.j, str, str.getClass()).tap do |o|
            Rhino::To.ruby(o).should == "Hello World"
          end
        end
      end
    end
    
    it "converts javascript undefined into nil" do
      Rhino::To.ruby(Rhino::JS::Undefined.instance).should be_nil
    end
  end
  
  describe  "javascript translation" do
    
    it "passes primitives through to the js layer to let jruby and rhino do he thunking" do
      to(1).should be(1)
      to(2.5).should == 2.5
      to("foo").should == "foo"
      to(true).should be(true)
      to(false).should be(false)      
    end
    
    it "unwraps wrapped ruby objects before passing them to the javascript runtime" do
      Rhino::JS::NativeObject.new.tap do |o|
        Rhino::To.javascript(Rhino::NativeObject.new(o)).should be(o)
      end        
    end
    
    it "leaves native javascript objects alone" do
      Rhino::JS::NativeObject.new.tap do |o|
        Rhino::To.javascript(o).should be(o)
      end
    end
    
    it "converts ruby arrays into javascript arrays" do
      Rhino::To.javascript([1,2,3,4,5]).tap do |a|
        a.should be_kind_of(Rhino::JS::NativeArray)
        a.get(0,a).should be(1)
        a.get(1,a).should be(2)
        a.get(2,a).should be(3)
        a.get(3,a).should be(4)
      end
    end

    it "converts ruby hashes into native objects" do
      Rhino::To.javascript({ :bare => true }).tap do |h|
        h.should be_kind_of(Rhino::JS::NativeObject)
        h.get("bare", h).should be(true)
      end
    end
    
    it "converts procs and methods into native functions" do
      to(lambda {|lhs,rhs| lhs * rhs}).tap do |f|
        f.should be_kind_of(Rhino::JS::Function)
        f.call(nil, nil, nil, [7,6]).should be(42)
      end
      to("foo,bar,baz".method(:split)).tap do |m|
        m.should be_kind_of(Rhino::JS::Function)
        Rhino::To.ruby(m.call(nil, nil, nil, ',')).should == ['foo', 'bar', 'baz']
      end
    end

    it "creates a prototype for the object based on its class" do
      Class.new.tap do |c|
        c.class_eval do
          def foo(one, two)
            "1: #{one}, 2: #{two}"
          end
        end

        Rhino::To.javascript(c.new).tap do |o|
          o.should be_kind_of(Rhino::RubyObject)
          o.prototype.tap do |p|
            p.should_not be_nil
            p.get("foo", p).should_not be_nil
            p.get("toString", p).should_not be_nil
          end
        end
      end
    end    
  end
  
  def to(object)
    Rhino::To.javascript(object)
  end
  
end
