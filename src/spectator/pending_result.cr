require "./result"

module Spectator
  # Outcome that indicates running an example was pending.
  # A pending result means the example is not ready to run yet.
  # This can happen when the functionality to be tested is not implemented yet.
  class PendingResult < Result
    # Creates the result.
    # *elapsed* is the length of time it took to run the example.
    def initialize(elapsed = Time::Span::ZERO, expectations = [] of Expectation)
      super
    end

    # Calls the `pending` method on the *visitor*.
    def accept(visitor)
      visitor.pending
    end

    # Calls the `pending` method on the *visitor*.
    def accept(visitor)
      visitor.pending(yield self)
    end

    # Indicates whether the example passed.
    def pass? : Bool
      false
    end

    # Indicates whether the example failed.
    def fail? : Bool
      false
    end

    # One-word description of the result.
    def to_s(io)
      io << "pending"
    end
  end
end
