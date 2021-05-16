require "./result"

module Spectator
  # Outcome that indicates an example failed.
  # This typically means an assertion did not pass.
  class FailResult < Result
    # Error that occurred while running the example.
    # This describes the primary reason for the failure.
    getter error : Exception

    # Creates a failure result.
    # The *elapsed* argument is the length of time it took to run the example.
    # The *error* is the exception raised that caused the failure.
    def initialize(elapsed, @error, expectations = [] of Expectation)
      super(elapsed, expectations)
    end

    # Calls the `failure` method on *visitor*.
    def accept(visitor)
      visitor.fail
    end

    # Calls the `failure` method on *visitor*.
    def accept(visitor)
      visitor.fail(yield self)
    end

    # Indicates whether the example passed.
    def pass? : Bool
      false
    end

    # Indicates whether the example failed.
    def fail? : Bool
      true
    end

    # One-word description of the result.
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
