require "./result"

module Spectator
  # Outcome that indicates an example failed.
  # This typically means an assertion did not pass.
  class FailResult < Result
    # Error that occurred while running the example.
    # This describes the primary reason for the failure.
    getter error : Exception

    # Creates a failure result.
    # The *elapsed* argument is the length of time it took to run the example.
    # The *error* is the exception raised that caused the failure.
    def initialize(elapsed, @error)
      super(elapsed)
    end

    # Calls the `failure` method on *visitor*.
    def accept(visitor)
      visitor.failure
    end

    # One-word description of the result.
    def to_s(io)
      io << "fail"
    end
  end
end
