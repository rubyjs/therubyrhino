require File.expand_path('../spec_helper', File.dirname(__FILE__))

require 'redjs/load_specs'

puts "will run JavaScript specs from RedJS #{RedJS::VERSION}"

describe Rhino::Context do
  
  it_behaves_like 'RedJS::Context'
  
  it "keeps objects iterable when property accessor is provided" do
    klass = Class.new do
      def [](name); name; end
      attr_accessor :foo
      def bar=(bar); bar; end 
    end

    RedJS::Context.new do |cxt|
      cxt['o'] = klass.new
      cxt.eval('a = new Array(); for (var i in o) a.push(i);')
      cxt['a'].length.should == 2 # [ 'foo', 'bar' ]
    end
  end
  
end