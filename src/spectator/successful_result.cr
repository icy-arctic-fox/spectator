require "./finished_result"

module Spectator
  # Outcome that indicates running an example was successful.
  class SuccessfulResult < FinishedResult
    # The expectations that were run in the example.
    getter expectations : Expectations::ExampleExpectations

    # Creates a successful result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    # The `elapsed` argument is the length of time it took to run the example.
    # The `expectations` references the expectations that were checked in the example.
    def initialize(example, elapsed, @expectations)
      super(example, elapsed)
    end

    # Calls the `success` method on `interface` and passes `self`.
    def call(interface)
      interface.success(self)
    end
  end
end
