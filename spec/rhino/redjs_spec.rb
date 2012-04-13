require File.expand_path('../spec_helper', File.dirname(__FILE__))

require 'redjs/load_specs'

puts "will run JavaScript specs from RedJS #{RedJS::VERSION}"

describe Rhino::Context do
  
  it_behaves_like 'RedJS::Context'
  
end