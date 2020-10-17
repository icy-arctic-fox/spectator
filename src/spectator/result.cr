module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # The assertions checked in the example.
    # getter assertions : Enumerable(Assertion) # TODO: Implement Assertion type.

    # Creates the result.
    # *elapsed* is the length of time it took to run the example.
    def initialize(@elapsed)
    end

    # Calls the corresponding method for the type of result.
    # This is the visitor design pattern.
    abstract def accept(visitor)
  end
end
