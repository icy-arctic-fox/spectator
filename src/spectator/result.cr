module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Example that was run that this result is for.
    getter example : Example

    # Indicates that an example was run and it was successful.
    # NOTE: Examples with warnings count as successful.
    abstract def passed? : Bool

    # Indicates that an example was run, but it failed.
    # Errors count as failures.
    abstract def failed? : Bool

    # Indicates whether an error was encountered while running the example.
    abstract def errored? : Bool

    # Indicates that an example was marked as pending.
    abstract def pending? : Bool

    # Constructs the base of the result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    def initialize(@example)
    end
  end
end
