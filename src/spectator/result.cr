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
  end
end
