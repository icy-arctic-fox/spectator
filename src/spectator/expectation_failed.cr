require "./example_failed"
require "./expectation"

module Spectator
  # Exception that indicates an expectation from a test failed.
  # When raised within a test, the test should abort.
  class ExpectationFailed < ExampleFailed
    # Expectation that failed.
    getter expectation : Expectation

    # Creates the exception.
    def initialize(@expectation : Expectation, message : String? = nil, cause : Exception? = nil)
      super(expectation.location?, message, cause)
    end
  end
end
