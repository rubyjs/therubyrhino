require File.expand_path('../spec_helper', File.dirname(__FILE__))

shared_examples_for Rhino::Ruby::Scriptable, :shared => true do

  it "puts, gets and has a read/write attr" do
    start = mock('start')
    start.expects(:put).never
    
    @wrapper.unwrap.instance_eval do
      def foo; @foo; end
      def foo=(foo); @foo = foo; end
    end
    
    @wrapper.put('foo', start, 42)
    @wrapper.has('foo', nil).should == true
    @wrapper.get('foo', nil).should == 42
    @wrapper.unwrap.instance_variable_get(:'@foo').should == 42
  end

  it "puts, gets and has a write only attr" do
    start = mock('start')
    start.expects(:put).never
    
    @wrapper.unwrap.instance_eval do
      def foo=(foo); @foo = foo; end
    end
    
    @wrapper.put('foo', start, 42)
    @wrapper.has('foo', nil).should == true
    @wrapper.get('foo', nil).should be(nil)
    @wrapper.unwrap.instance_variable_get(:'@foo').should == 42
  end

  it "puts, gets and has gets delegated if it acts like a Hash" do
    start = mock('start')
    start.expects(:put).never
    
    @wrapper.unwrap.instance_eval do
      def [](name); (@hash ||= {})[name]; end
      def []=(name, value); (@hash ||= {})[name] = value; end
    end
    
    @wrapper.put('foo', start, 42)
    @wrapper.has('foo', nil).should == true
    @wrapper.get('foo', nil).should == 42
    @wrapper.unwrap.instance_variable_get(:'@hash')['foo'].should == 42
  end
  
  it "puts, gets and has non-existing property" do
    start = mock('start')
    start.expects(:put).once
    
    @wrapper.put('foo', start, 42)
    @wrapper.has('foo', nil).should == false
    @wrapper.get('foo', nil).should be(Rhino::JS::Scriptable::NOT_FOUND)
  end
  
end

describe Rhino::Ruby::Object do
  
  before do
    @wrapper = Rhino::Ruby::Object.wrap @object = Object.new
  end
  
  it "unwraps a ruby object" do
    @wrapper.unwrap.should be(@object)
  end
  
  it_should_behave_like Rhino::Ruby::Scriptable
  
  class UII < Object
  end
  
  it "returns the ruby class name" do
    rb_object = Rhino::Ruby::Object.wrap UII.new
    rb_object.getClassName.should == UII.name
  end
  
  it "reports being a ruby object on toString" do
    rb_object = Rhino::Ruby::Object.wrap UII.new
    rb_object.toString.should == '[ruby UII]'
  end
  
  class UII
    
    attr_reader :anAttr0
    attr_accessor :the_attr_1
    
    def initialize
      @anAttr0 = nil
      @the_attr_1 = 'attr_1'
      @an_attr_2 = 'attr_2'
    end
    
    def theMethod0; @theMethod0; end
    
    def a_method1; 1; end
    
    def the_method_2; '2'; end
    
  end
  
  it "gets methods and instance variables" do
    rb_object = Rhino::Ruby::Object.wrap UII.new
    
    rb_object.get('anAttr0', nil).should be_nil
    rb_object.get('the_attr_1', nil).should == 'attr_1'
    rb_object.get('an_attr_2', nil).should be(Rhino::JS::Scriptable::NOT_FOUND) # no reader
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.get(name, nil).should be_a(Rhino::Ruby::Function)
    end
    
    rb_object.get('non-existent-method', nil).should be(Rhino::JS::Scriptable::NOT_FOUND)
  end

  it "has methods and instance variables" do
    rb_object = Rhino::Ruby::Object.wrap UII.new
    
    rb_object.has('anAttr0', nil).should be_true
    rb_object.has('the_attr_1', nil).should be_true
    rb_object.has('an_attr_2', nil).should be_false # no reader nor writer
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.has(name, nil).should be_true
    end
    
    rb_object.has('non-existent-method', nil).should be_false
  end
  
  it "puts using attr writer" do
    start = mock('start')
    start.expects(:put).never
    rb_object = Rhino::Ruby::Object.wrap UII.new
    
    rb_object.put('the_attr_1', start, 42)
    rb_object.the_attr_1.should == 42
  end

  it "puts a non-existent attr (delegates to start)" do
    start = mock('start')
    start.expects(:put).once
    rb_object = Rhino::Ruby::Object.wrap UII.new
    
    rb_object.put('nonExistingAttr', start, 42)
  end

  it "getIds include ruby class methods" do
    rb_object = Rhino::Ruby::Object.wrap UII.new
    
    [ 'anAttr0', 'the_attr_1' ].each do |attr|
      rb_object.getIds.to_a.should include(attr)
    end
    rb_object.getIds.to_a.should_not include('an_attr_2')
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |method|
      rb_object.getIds.to_a.should include(method)
    end
  end

  it "getIds include ruby instance methods" do
    rb_object = Rhino::Ruby::Object.wrap object = UII.new
    object.instance_eval do
      def foo; 'foo'; end
    end
    
    rb_object.getIds.to_a.should include('foo')
  end
  
  it "getIds include writers as attr names" do
    rb_object = Rhino::Ruby::Object.wrap object = UII.new
    
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
  
  describe 'with scope' do
    
    before do
      factory = Rhino::JS::ContextFactory.new
      context = nil
      factory.call do |ctx|
        context = ctx
        @scope = context.initStandardObjects(nil, false)
      end
      factory.enterContext(context)
    end

    after do
      Rhino::JS::Context.exit
    end
    
    it "sets up correct prototype" do
      rb_object = Rhino::Ruby::Object.wrap UII.new, @scope
      rb_object.getPrototype.should_not be(nil)
      rb_object.getPrototype.should be_a(Rhino::JS::NativeObject)
    end
    
  end
  
  it "is aliased to RubyObject" do
    (!! defined? Rhino::RubyObject).should == true
    Rhino::RubyObject.should be(Rhino::Ruby::Object)
  end
  
end

describe Rhino::Ruby::Function do
  
  before do
    @wrapper = Rhino::Ruby::Function.wrap @method = Object.new.method(:to_s)
  end
  
  it "unwraps a ruby method" do
    @wrapper.unwrap.should be(@method)
  end
  
  it_should_behave_like Rhino::Ruby::Scriptable

  it "is callable as a function" do
    rb_function = Rhino::Ruby::Function.wrap method = 'foo'.method(:to_s)
    context = nil; scope = nil; this = nil; args = nil
    rb_function.call(context, scope, this, args).should == 'foo'
  end

  it "args get converted before delegating a ruby function call" do
    klass = Class.new(Object) do
      def foo(array)
        array.all? { |elem| elem.is_a?(String) }
      end
    end
    rb_function = Rhino::Ruby::Function.wrap method = klass.new.method(:foo)
    context = nil; scope = nil; this = nil
    args = [ '1'.to_java, java.lang.String.new('2') ].to_java
    args = [ Rhino::JS::NativeArray.new(args) ].to_java
    rb_function.call(context, scope, this, args).should be(true)
  end

  it "returned value gets converted to javascript" do
    klass = Class.new(Object) do
      def foo
        [ 42 ]
      end
    end
    rb_function = Rhino::Ruby::Function.wrap method = klass.new.method(:foo)
    context = nil; scope = nil; this = nil; args = [].to_java
    rb_function.call(context, scope, this, args).should be_a(Rhino::JS::NativeArray)
  end
  
  it "returns correct arity and length" do
    klass = Class.new(Object) do
      def foo(a1, a2)
        a1 || a2
      end
    end
    rb_function = Rhino::Ruby::Function.wrap klass.new.method(:foo)
    rb_function.getArity.should == 2
    rb_function.getLength.should == 2
  end

  describe 'with scope' do
    
    before do
      factory = Rhino::JS::ContextFactory.new
      context = nil
      factory.call do |ctx|
        context = ctx
        @scope = context.initStandardObjects(nil, false)
      end
      factory.enterContext(context)
    end

    after do
      Rhino::JS::Context.exit
    end
    
    it "sets up correct prototype" do
      rb_function = Rhino::Ruby::Function.wrap 'foo'.method(:concat), @scope
      rb_function.getPrototype.should_not be(nil)
      rb_function.getPrototype.should be_a(Rhino::JS::Function)
    end
    
  end
  
  it "is aliased to RubyFunction" do
    (!! defined? Rhino::RubyFunction).should == true
    Rhino::RubyFunction.should be(Rhino::Ruby::Function)
  end
  
end

describe Rhino::Ruby::Constructor do
  
  before do
    @wrapper = Rhino::Ruby::Constructor.wrap @class = Class.new(Object)
  end
  
  it "unwraps a ruby method" do
    @wrapper.unwrap.should be(@class)
  end
  
  it_should_behave_like Rhino::Ruby::Scriptable

  class Foo < Object
  end
  
  it "is callable as a function" do
    rb_new = Rhino::Ruby::Constructor.wrap Foo
    context = nil; scope = nil; this = nil; args = nil
    rb_new.call(context, scope, this, args).should be_a(Rhino::Ruby::Object)
    rb_new.call(context, scope, this, args).unwrap.should be_a(Foo)
  end
  
  it "returns correct arity and length" do
    rb_new = Rhino::Ruby::Constructor.wrap Foo
    rb_new.getArity.should == 0
    rb_new.getLength.should == 0
  end

  describe 'with scope' do
    
    before do
      factory = Rhino::JS::ContextFactory.new
      context = nil
      factory.call do |ctx|
        context = ctx
        @scope = context.initStandardObjects(nil, false)
      end
      factory.enterContext(context)
    end

    after do
      Rhino::JS::Context.exit
    end
    
    it "sets up correct prototype" do
      rb_function = Rhino::Ruby::Function.wrap 'foo'.method(:concat), @scope
      rb_function.getPrototype.should_not be(nil)
      rb_function.getPrototype.should be_a(Rhino::JS::Function)
    end
    
  end
  
  it "is aliased to RubyConstructor" do
    (!! defined? Rhino::RubyConstructor).should == true
    Rhino::RubyConstructor.should be(Rhino::Ruby::Constructor)
  end
  
end
