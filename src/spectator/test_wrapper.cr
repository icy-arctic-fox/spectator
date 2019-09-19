require "../spectator_test"
require "./source"

module Spectator
  alias TestMethod = ::SpectatorTest ->

  # Stores information about a end-user test.
  # Used to instantiate tests and run them.
  struct TestWrapper
    # Description the user provided for the test.
    getter description

    # Location of the test in source code.
    getter source

    # Creates a wrapper for the test.
    def initialize(@description : String, @source : Source, @test : ::SpectatorTest, @runner : TestMethod)
    end

    def run
      call(@runner)
    end

    def call(method : TestMethod) : Nil
      method.call(@test)
    end

    def around_hook(context : TestContext)
      context.wrap_around_each_hooks(@test) { run }
    end
  end
end
