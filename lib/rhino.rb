$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Rhino
  VERSION = '1.72.0'
  require 'rhino/java'
  require 'rhino/context'
  require 'rhino/wormhole'
  require 'rhino/native_object'
end