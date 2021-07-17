module Spectator
  # Exception that indicates an example is pending and should be skipped.
  # When raised within a test, the test should abort.
  class ExamplePending < Exception
    # Location of where the example was aborted.
    getter location : Location?

    # Creates the exception.
    # Specify *location* to where the example was aborted.
    def initialize(@location : Location? = nil, message : String? = nil, cause : Exception? = nil)
      super(message, cause)
    end
  end
end
