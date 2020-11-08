require "./context"
require "./example_context_method"
require "./null_context"

module Spectator
  # Stores a test context and a method to call within it.
  # This is a variant of `ContextDelegate` that accepts the current running example.
  struct ExampleContextDelegate
    # Retrieves the underlying context.
    protected getter context : Context

    # Creates the delegate.
    # The *context* is the instance of the test context.
    # The *method* is proc that downcasts *context* and calls a method on it.
    def initialize(@context : Context, @method : ExampleContextMethod)
    end

    # Creates a delegate with a null context.
    # The context will be ignored and the block will be executed in its original scope.
    # The example instance will be provided as an argument to the block.
    def self.null(&block : Example -> _)
      context = NullContext.new
      method = ExampleContextMethod.new { |example| block.call(example) }
      new(context, method)
    end

    # Invokes a method in the test context.
    # The *example* is the current running example.
    def call(example : Example)
      @method.call(example, @context)
    end
  end
end
