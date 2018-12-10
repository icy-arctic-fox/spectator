require "./result"

module Spectator
  # Outcome that indicates running an example was successful.
  class SuccessfulResult < Result
    # The expectations that were run in the example.
    getter expectations : Expectations::ExampleExpectations

    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # Creates a successful result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    # The `elapsed` argument is the length of time it took to run the example.
    # The `expectations` references the expectations that were checked in the example.
    def initialize(example, @elapsed, @expectations)
      super(example)
    end

    # Indicates that an example was run and it was successful.
    # NOTE: Examples with warnings count as successful.
    # This will always be true for this type of result.
    def passed?
      true
    end

    # Indicates that an example was run, but it failed.
    # Errors count as failures.
    # This will always be false for this type of result.
    def failed?
      false
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
