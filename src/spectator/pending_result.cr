require "./result"

module Spectator
  # Outcome that indicates running an example was pending.
  # A pending result means the example is not ready to run yet.
  # This can happen when the functionality to be tested is not implemented yet.
  class PendingResult < Result
    # Creates a pending result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    def initialize(example)
      super(example, Time::Span.zero)
    end

    # Indicates that an example was run and it was successful.
    # NOTE: Examples with warnings count as successful.
    # This will always be false for this type of result.
    def passed?
      false
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
    # This will always be true for this type of result.
    def pending?
      true
    end
  end
end
