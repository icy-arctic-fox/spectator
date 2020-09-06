require "./context"
require "./example_context_method"

module Spectator
  # Stores a test context and a method to call within it.
  # This is a variant of `ContextDelegate` that accepts the current running example.
  struct ExampleContextDelegate
    # Creates the delegate.
    # The *context* is the instance of the test context.
    # The *method* is proc that downcasts *context* and calls a method on it.
    def initialize(@context : Context, @method : ExampleContextMethod)
    end

    # Invokes a method in the test context.
    # The *example* is the current running example.
    def call(example : Example)
      @method.call(example, @context)
    end
  end
end
