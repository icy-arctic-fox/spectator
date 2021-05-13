require "./result"

module Spectator
  # Outcome that indicates running an example was successful.
  class PassResult < Result
    # Calls the `pass` method on *visitor*.
    def accept(visitor)
      visitor.pass
    end

    # Calls the `pass` method on *visitor*.
    def accept(visitor)
      visitor.pass(yield self)
    end

    # Indicates whether the example passed.
    def pass? : Bool
      true
    end

    # Indicates whether the example failed.
    def fail? : Bool
      false
    end

    # One-word description of the result.
    def to_s(io)
      io << "pass"
    end
  end
end
