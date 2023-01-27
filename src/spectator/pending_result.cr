require "./result"

module Spectator
  # Outcome that indicates running an example was pending.
  # A pending result means the example is not ready to run yet.
  # This can happen when the functionality to be tested is not implemented yet.
  class PendingResult < Result
    DEFAULT_REASON = "No reason given"

    # Reason the example was skipped or marked pending.
    getter reason : String

    # Location the pending result was triggered from.
    getter! location : Location

    # Creates the result.
    # *elapsed* is the length of time it took to run the example.
    # A *reason* for the skip/pending result can be specified.
    # If the pending result was triggered inside of an example, then *location* can be set.
    def initialize(@reason = DEFAULT_REASON, @location = nil,
                   elapsed = Time::Span::ZERO, expectations = [] of Expectation)
      super(elapsed, expectations)
    end

    # Calls the `pending` method on the *visitor*.
    def accept(visitor)
      visitor.pending(self)
    end

    # Calls the `pending` method on the *visitor*.
    def accept(visitor, &)
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
    def to_s(io : IO) : Nil
      io << "pending"
    end

    # Creates a JSON object from the result information.
    def to_json(json : JSON::Builder)
      super
      json.field("status", "pending")
      json.field("pending_message", @reason)
    end
  end
end
