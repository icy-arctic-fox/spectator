require "./finished_result"

module Spectator
  # Outcome that indicates running an example was successful.
  class SuccessfulResult < FinishedResult
    # Calls the `success` method on *interface*.
    def call(interface)
      interface.success
    end

    # Calls the `success` method on *interface*
    # and passes the yielded value.
    def call(interface)
      value = yield self
      interface.success(value)
    end

    # One-word descriptor of the result.
    def to_s(io)
      io << "success"
    end
  end
end
