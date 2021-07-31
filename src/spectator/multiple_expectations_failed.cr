require "./example_failed"
require "./expectation"

module Spectator
  # Exception that indicates more than one expectation from a test failed.
  # When raised within a test, the test should abort.
  class MultipleExpectationsFailed < ExampleFailed
    # Expectations that failed.
    getter expectations : Array(Expectation)

    # Creates the exception.
    def initialize(@expectations : Array(Expectation), message : String? = nil, cause : Exception? = nil)
      super(nil, message, cause)
    end
  end
end
