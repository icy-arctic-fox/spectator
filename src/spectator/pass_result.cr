require "./result"

module Spectator
  # Outcome that indicates running an example was successful.
  class PassResult < Result
    # Calls the `pass` method on *visitor*.
    def accept(visitor)
      visitor.pass
    end

    # One-word description of the result.
    def to_s(io)
      io << "pass"
    end
  end
end
