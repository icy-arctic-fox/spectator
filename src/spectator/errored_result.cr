require "./failed_result"

module Spectator
  # Outcome that indicates running an example generated an error.
  # This type of result occurs when an exception was raised.
  # This is different from a "failed" result
  # in that the error was not from a failed expectation.
  class ErroredResult < FailedResult
    # Calls the `error` method on *interface*.
    def call(interface)
      interface.error
    end

    # Calls the `error` method on *interface*
    # and passes the yielded value.
    def call(interface)
      value = yield self
      interface.error(value)
    end

    # One-word descriptor of the result.
    def to_s(io)
      io << "error"
    end
  end
end
