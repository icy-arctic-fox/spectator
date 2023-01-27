require "json"
require "./example_failed"
require "./location"
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
      visitor.fail(self)
    end

    # Calls the `failure` method on *visitor*.
    def accept(visitor, &)
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

    # Attempts to retrieve the location where the example failed.
    # This only works if the location of the failed expectation was reported.
    # If available, returns a `Location`, otherwise `nil`.
    def location? : Location?
      return unless error = @error.as?(ExampleFailed)

      error.location?
    end

    # Attempts to retrieve the location where the example failed.
    # This only works if the location of the failed expectation was reported.
    # If available, returns a `Location`, otherwise raises `NilAssertionError`.
    def location : Location
      location? || raise(NilAssertionError.new("Source location of failure unavailable"))
    end

    # One-word description of the result.
    def to_s(io : IO) : Nil
      io << "fail"
    end

    # Creates a JSON object from the result information.
    def to_json(json : JSON::Builder)
      super
      json.field("status", json_status)
      json.field("exception") do
        json.object do
          json.field("class", @error.class.name)
          json.field("message", @error.message)
          json.field("backtrace", @error.backtrace)
        end
      end
    end

    # String used for the JSON status field.
    # Necessary for the error result to override the status, but nothing else from `#to_json`.
    private def json_status
      "failed"
    end
  end
end
