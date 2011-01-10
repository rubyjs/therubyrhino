$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Rhino
  VERSION = '1.72.7'
  require 'rhino/java'
  require 'rhino/object'
  require 'rhino/context'
  require 'rhino/wormhole'
  require 'rhino/ruby_object'
  require 'rhino/ruby_function'
  require 'rhino/native_object'
  require 'rhino/native_function'
end