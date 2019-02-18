require "./result"

module Spectator
  # Outcome that indicates running an example was a failure.
  class FailedResult < FinishedResult
    # Error that occurred while running the example.
    getter error : Exception

    # The expectations that were run in the example.
    getter expectations : Expectations::ExampleExpectations

    # Creates a failed result.
    # The *example* should refer to the example that was run
    # and that this result is for.
    # The *elapsed* argument is the length of time it took to run the example.
    # The *expectations* references the expectations that were checked in the example.
    # The *error* is the exception that was raised to cause the failure.
    def initialize(example, elapsed, @expectations, @error)
      super(example, elapsed)
    end

    # Calls the `failure` method on *interface* and passes self.
    def call(interface)
      interface.failure(self)
    end
  end
end
