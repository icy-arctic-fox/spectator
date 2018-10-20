require "./example_failed"

module Spectator
  # Exception that indicates a required expectation was not met in an example.
  class ExpectationFailed < ExampleFailed
    # Outcome of the expectation.
    # Additional information can be retrieved through this.
    getter result : Expectations::Expectation::Result

    # Creates the exception.
    # The exception string is generated from the expecation message.
    def initialize(@result)
      super(@result.actual_message)
    end
  end
end
