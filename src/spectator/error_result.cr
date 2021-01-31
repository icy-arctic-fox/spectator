require "./fail_result"

module Spectator
  # Outcome that indicates running an example generated an error.
  # This occurs when an unexpected exception was raised while running an example.
  # This is different from a "failed" result in that the error was not from a failed assertion.
  class ErrorResult < FailResult
    # Calls the `error` method on *visitor*.
    def accept(visitor)
      visitor.error
    end

    # Calls the `error` method on *visitor*.
    def accept(visitor)
      visitor.error(yield self)
    end

    # One-word description of the result.
    def to_s(io)
      io << "error"
    end

    # TODO
    def to_json(builder)
      builder.string("ERROR")
    end
  end
end
