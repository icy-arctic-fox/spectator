require "./context"
require "./context_method"

module Spectator
  # Stores a test context and a method to call within it.
  struct ContextDelegate
    # Creates the delegate.
    # The *context* is the instance of the test context.
    # The *method* is proc that downcasts *context* and calls a method on it.
    def initialize(@context : Context, @method : ContextMethod)
    end

    # Invokes a method in the test context.
    def call
      @method.call(@context)
    end
  end
end
