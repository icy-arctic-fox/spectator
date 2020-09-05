require "./example_node"
require "./result"

module Spectator
  # Common base type for all examples.
  abstract class ExampleBase < ExampleNode
    # Retrieves the result of the last time the example ran.
    # This will be nil if the example hasn't run,
    # and should not be nil if it has.
    abstract def result? : Result?

    # Retrieves the result of the last time the example ran.
    # Raises an error if the example hasn't run.
    def result : Result
      result? || raise(NilAssertionError("Example has no result"))
    end

    # Exposes information about the example useful for debugging.
    def inspect(io)
      raise NotImplementedError.new("#inspect")
    end
  end
end
