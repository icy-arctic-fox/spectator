require "./result"

module Spectator
  # Outcome that indicates running an example was pending.
  # A pending result means the example is not ready to run yet.
  # This can happen when the functionality to be tested is not implemented yet.
  class PendingResult < Result
    # Calls the `pending` method on *interface*.
    def call(interface)
      interface.pending
    end

    # Calls the `pending` method on *interface*
    # and passes the yielded value.
    def call(interface)
      value = yield self
      interface.pending(value)
    end

    # One-word descriptor of the result.
    def to_s(io)
      io << "pending"
    end
  end
end
