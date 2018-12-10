module Spectator
  # Abstract class for all results by examples
  abstract class FinishedResult < Result
    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # Creates a successful result.
    # The `example` should refer to the example that was run
    # and that this result is for.
    # The `elapsed` argument is the length of time it took to run the example.
    def initialize(example, @elapsed)
      super(example)
    end

    # Indicates that an example was marked as pending.
    # This will always be false for this type of result.
    def pending?
      false
    end
  end
end
