require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Rhino::RubyObject do
  
  it "unwraps a ruby object" do
    rb_object = Rhino::RubyObject.new object = Object.new
    rb_object.unwrap.should be(object)
  end

  class UII < Object
  end
  
  it "returns the ruby class name" do
    rb_object = Rhino::RubyObject.new UII.new
    rb_object.getClassName.should == UII.name
  end
  
  it "reports being a ruby object on toString" do
    rb_object = Rhino::RubyObject.new UII.new
    rb_object.toString.should == '[ruby UII]'
  end

  class UII
    
    attr_reader :anAttr0
    attr_accessor :the_attr_1
    
    def initialize
      @anAttr0 = nil
      @the_attr_1 = 'attr_1'
      @an_attr_2 = 'an_attr_2'
    end
    
    def theMethod0; nil; end
    
    def a_method1; 1; end
    
    def the_method_2; '2'; end
    
  end
  
  it "gets methods and instance variables" do
    rb_object = Rhino::RubyObject.new UII.new
    
    rb_object.get('anAttr0', nil).should be_a(Rhino::RubyFunction)
    rb_object.get('the_attr_1', nil).should be_a(Rhino::RubyFunction)
    rb_object.get('an_attr_2', nil).should == 'an_attr_2'
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.get(name, nil).should be_a(Rhino::RubyFunction)
    end
    
    rb_object.get('non-existent-method', nil).should be(Rhino::JS::Scriptable::NOT_FOUND)
  end

  it "has methods and instance variables" do
    rb_object = Rhino::RubyObject.new UII.new
    
    rb_object.has('anAttr0', nil).should be_true
    rb_object.has('the_attr_1', nil).should be_true
    rb_object.has('an_attr_2', nil).should be_true
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.has(name, nil).should be_true
    end
    
    rb_object.has('non-existent-method', nil).should be_false
  end
  
  it "puts using attr writer" do
    start = mock('start')
    start.expects(:put).never
    rb_object = Rhino::RubyObject.new UII.new
    
    rb_object.put('the_attr_1', start, 42)
    rb_object.the_attr_1.should == 42
  end

  it "puts a non-existent attr (delegates to start)" do
    start = mock('start')
    start.expects(:put).once
    rb_object = Rhino::RubyObject.new UII.new
    
    rb_object.put('nonExistingAttr', start, 42)
  end

  it "getIds include ruby class methods" do
    rb_object = Rhino::RubyObject.new UII.new
    
    [ 'anAttr0', 'the_attr_1', 'an_attr_2' ].each do |attr|
      rb_object.getIds.to_a.should include(attr)
    end
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |method|
      rb_object.getIds.to_a.should include(method)
    end
  end

  it "getIds include ruby instance methods" do
    rb_object = Rhino::RubyObject.new object = UII.new
    object.instance_eval do
      def foo; 'foo'; end
    end
    
    rb_object.getIds.to_a.should include('foo')
  end
  
  it "getIds include writers as attr names" do
    rb_object = Rhino::RubyObject.new object = UII.new
    
    rb_object.getIds.to_a.should include('the_attr_1')
    rb_object.getIds.to_a.should_not include('the_attr_1=')
    
    object.instance_eval do
      def foo=(foo)
        'foo'
      end
    end

    rb_object.getIds.to_a.should include('foo')
    rb_object.getIds.to_a.should_not include('foo=')
  end
  
end