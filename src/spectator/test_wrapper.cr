require "../spectator_test"
require "./source"

module Spectator
  alias TestMethod = ::SpectatorTest ->

  # Stores information about a end-user test.
  # Used to instantiate tests and run them.
  struct TestWrapper
    # Location of the test in source code.
    getter source : Source

    # Description the user provided for the test.
    getter description : String

    # Creates a wrapper for the test.
    # The *builder* creates an instance of the test.
    # The *runner* takes the test created by *builder* and runs it.
    def initialize(@description, @source, @builder : -> ::SpectatorTest, @runner : TestMethod)
    end

    # Instantiates and runs the test.
    # This method yields twice - before and after the test.
    # The test instance is yielded.
    def run : Nil
      test = @builder.call
      yield test
      @runner.call(test)
      yield test
    end
  end
end
