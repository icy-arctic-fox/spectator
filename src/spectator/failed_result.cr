require "./result"

module Spectator
  # Outcome that indicates running an example was a failure.
  class FailedResult < FinishedResult
    # Error that occurred while running the example.
    getter error : Exception

    # Creates a failed result.
    # The *example* should refer to the example that was run
    # and that this result is for.
    # The *elapsed* argument is the length of time it took to run the example.
    # The *expectations* references the expectations that were checked in the example.
    # The *error* is the exception that was raised to cause the failure.
    def initialize(example, elapsed, expectations, @error)
      super(example, elapsed, expectations)
    end

    # Calls the `failure` method on *interface*.
    def call(interface)
      interface.failure
    end

    # Calls the `failure` method on *interface*
    # and passes the yielded value.
    def call(interface)
      value = yield self
      interface.failure(value)
    end

    # One-word descriptor of the result.
    def to_s(io)
      io << "fail"
    end

    # Adds all of the JSON fields for finished results and failed results.
    private def add_json_fields(json : ::JSON::Builder)
      super
      json.field("error", error.message)
    end
  end
end
