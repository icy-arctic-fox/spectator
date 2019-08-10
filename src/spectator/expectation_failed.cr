require "./example_failed"

module Spectator
  # Exception that indicates a required expectation was not met in an example.
  class ExpectationFailed < ExampleFailed
    # Expectation that failed.
    getter expectation : Expectations::Expectation

    # Creates the exception.
    # The exception string is generated from the expecation message.
    def initialize(@expectation)
      super(@expectation.failure_message)
    end
  end
end
