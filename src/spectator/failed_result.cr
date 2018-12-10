require "./result"

module Spectator
  # Outcome that indicates running an example was a failure.
  class FailedResult < Result
    # Error that occurred while running the example.
    getter error : Exception

    # The expectations that were run in the example.
    getter expectations : Expectations::ExampleExpectations

    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # Creates a failed result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    # The `elapsed` argument is the length of time it took to run the example.
    # The `expectations` references the expectations that were checked in the example.
    # The `error` is the exception that was raised to cause the failure.
    def initialize(example, @elapsed, @expectations, @error)
      super(example)
    end

    # Indicates that an example was run and it was successful.
    # NOTE: Examples with warnings count as successful.
    # This will always be false for this type of result.
    def passed?
      false
    end

    # Indicates that an example was run, but it failed.
    # Errors count as failures.
    # This will always be true for this type of result.
    def failed?
      true
    end

    # Indicates whether an error was encountered while running the example.
    # This will always be false for this type of result.
    def errored?
      false
    end

    # Indicates that an example was marked as pending.
    # This will always be false for this type of result.
    def pending?
      false
    end
  end
end
