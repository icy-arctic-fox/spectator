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

    # Adds the common JSON fields for all result types
    # and fields specific to errored results.
    private def add_json_fields(json : ::JSON::Builder)
      super
      json.field("exceptions") do
        exception = error
        json.array do
          while exception
            error_to_json(exception, json) if exception
            exception = error.cause
          end
        end
      end
    end

    # Adds a single exception to a JSON builder.
    private def error_to_json(error : Exception, json : ::JSON::Builder)
      json.object do
        json.field("type", error.class.to_s)
        json.field("message", error.message)
        json.field("backtrace", error.backtrace)
      end
    end
  end
end
