require "./context"
require "./context_method"
require "./null_context"

module Spectator
  # Stores a test context and a method to call within it.
  struct ContextDelegate
    # Creates the delegate.
    # The *context* is the instance of the test context.
    # The *method* is proc that downcasts *context* and calls a method on it.
    def initialize(@context : Context, @method : ContextMethod)
    end

    # Creates a delegate with a null context.
    # The context will be ignored and the block will be executed in its original scope.
    def self.null(&block : -> _)
      context = NullContext.new
      method = ContextMethod.new { block.call }
      new(context, method)
    end

    # Invokes a method in the test context.
    def call
      @method.call(@context)
    end
  end
end
