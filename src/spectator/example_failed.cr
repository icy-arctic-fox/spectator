require "./location"

module Spectator
  # Exception that indicates an example failed.
  # When raised within a test, the test should abort.
  class ExampleFailed < Exception
    getter! location : Location

    # Creates the exception.
    def initialize(@location : Location?, message : String? = nil, cause : Exception? = nil)
      super(message, cause)
    end
  end
end
