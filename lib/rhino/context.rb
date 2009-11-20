module Rhino

# ==Overview
#  All Javascript must be executed in a context which represents the execution environment in
#  which scripts will run. The environment consists of the standard javascript objects
#  and functions like Object, String, Array, etc... as well as any objects or functions which 
#  have been defined in it. e.g.
#  
#   Context.open do |cxt|
#     cxt['num'] = 5
#     cxt.eval('num + 5') #=> 10
#   end
# 
# == Multiple Contexts.
# The same object may appear in any number of contexts, but only one context may be executing javascript code 
# in any given thread. If a new context is opened in a thread in which a context is already opened, the second
# context will "mask" the old context e.g.
#
#   six = 6
#   Context.open do |cxt|
#     cxt['num'] = 5
#     cxt.eval('num') # => 5     
#     Context.open do |cxt|
#       cxt['num'] = 10
#       cxt.eval('num') # => 10
#       cxt.eval('++num') # => 11
#     end
#     cxt.eval('num') # => 5
#   end
#
# == Notes
# While there are many similarities between Rhino::Context and Java::OrgMozillaJavascript::Context, they are not
# the same thing and should not be confused.

  class Context    
    attr_reader :scope

    class << self
      
      # initalize a new context with a fresh set of standard objects. All operations on the context
      # should be performed in the block that is passed.
      def open(options = {}, &block)
        ContextFactory.new.call do |native|
          block.call(new(native, options))
        end
      end
                      
      private :new
    end    
    
    def initialize(native, options) #:nodoc:
      @native = native
      @global = NativeObject.new(@native.initStandardObjects(nil, options[:sealed] == true))
      if with = options[:with]
        @scope = To.javascript(with)
        @scope.setParentScope(@global.j)
      else
        @scope = @global
      end
      unless options[:java]
        for package in ["Packages", "java", "org", "com"]
          @global.j.delete(package)
        end
      end      
    end
    
    # Read a value from the global scope of this context
    def [](k)
      @scope[k]
    end

    # Set a value in the global scope of this context. This value will be visible to all the 
    # javascript that is executed in this context.    
    def []=(k,v)
      @scope[k] = v
    end

    # Evaluate a string of javascript in this context:
    # * <tt>source</tt> - the javascript source code to evaluate. This can be either a string or an IO object.
    # * <tt>source_name</tt> - associated name for this source code. Mainly useful for backtraces.
    # * <tt>line_number</tt> - associate this number with the first line of executing source. Mainly useful for backtraces
    def eval(source, source_name = "<eval>", line_number = 1)
      begin
        scope = To.javascript(@scope)
        if IO === source || StringIO === source
          result = @native.evaluateReader(scope, IOReader.new(source), source_name, line_number, nil)
        else          
          result = @native.evaluateString(scope, source.to_s, source_name, line_number, nil)
        end
        To.ruby result
      rescue J::RhinoException => e
        raise Rhino::RhinoError, e
      end
    end
  
    # Set the maximum number of instructions that this context will execute.
    # If this instruction limit is exceeded, then a Rhino::RunawayScriptError
    # will be raised
    def instruction_limit=(limit)
      @native.setInstructionObserverThreshold(limit);
      @native.factory.instruction_limit = limit
    end
        
  end

  class IOReader < Java::JavaIo::Reader #:nodoc:

    def initialize(io)
      @io = io
    end

    def read(charbuffer, offset, length)
      begin
        str = @io.read(length)
        if str.nil?
          return -1
        else
          jstring = Java::JavaLang::String.new(str)
          for i in 0 .. jstring.length - 1          
            charbuffer[i + offset] = jstring.charAt(i)
          end
          return jstring.length
        end
      rescue  StandardError => e        
        raise Java::JavaIo::IOException.new, "Failed reading from ruby IO object"
      end
    end
  end
      
  class ContextFactory < J::ContextFactory # :nodoc:
    
    def observeInstructionCount(cxt, count)
      raise RunawayScriptError, "script exceeded allowable instruction count" if count > @limit
    end
        
    def instruction_limit=(count)
      @limit = count
    end
  end
    
    
  class RhinoError < StandardError # :nodoc:
    def initialize(native)
      @native = native
    end
    
    def message      
      @native.cause.details
    end
    
    def javascript_backtrace
      @native.getScriptStackTrace()
    end        
  end
  
  class RunawayScriptError < StandardError # :nodoc:
  end 
end