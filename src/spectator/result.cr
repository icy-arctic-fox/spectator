module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Example that was run that this result is for.
    getter example : Example

    # Constructs the base of the result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    def initialize(@example)
    end

    # Calls the corresponding method for the type of result.
    # This is used to avoid placing if or case-statements everywhere based on type.
    # Each sub-class implements this method by calling the correct method on `interface`.
    abstract def call(interface)
  end
end
