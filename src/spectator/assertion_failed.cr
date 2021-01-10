require "./source"

module Spectator
  # Exception that indicates an assertion failed.
  # When raised within a test, the test should abort.
  class AssertionFailed < Exception
    # Location where the assertion failed and the exception raised.
    getter source : Source

    # Creates the exception.
    def initialize(@source : Source, message : String? = nil, cause : Exception? = nil)
      super(message, cause)
    end
  end
end
