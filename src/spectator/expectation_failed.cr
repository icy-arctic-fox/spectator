require "./expectation"

module Spectator
  # Exception that indicates an expectation from a test failed.
  # When raised within a test, the test should abort.
  class ExpectationFailed < Exception
    # Expectation that failed.
    getter expectation : Expectation

    # Creates the exception.
    def initialize(@expectation : Expectation, message : String? = nil, cause : Exception? = nil)
      super(message, cause)
    end
  end
end
