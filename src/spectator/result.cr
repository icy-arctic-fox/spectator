module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Example that generated the result.
    # TODO: Remove this.
    getter example : Example

    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # The assertions checked in the example.
    getter expectations : Enumerable(Expectation)

    # Creates the result.
    # *elapsed* is the length of time it took to run the example.
    def initialize(@example, @elapsed, @expectations = [] of Expectation)
    end

    # Calls the corresponding method for the type of result.
    # This is the visitor design pattern.
    abstract def accept(visitor)
  end
end
