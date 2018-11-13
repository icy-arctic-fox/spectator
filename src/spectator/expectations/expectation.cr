module Spectator::Expectations
  abstract class Expectation
    # Populates the base portiion of the expectation with values.
    # The `matched` flag should be true if the matcher is satisfied with the partial.
    # The `negated` flag should be true if the expectation is inverted.
    # These options are mutually-exclusive in this context.
    # Don't flip the value of `matched` because `negated` is true.
    def initialize(@matched : Bool, @negated : Bool)
    end

    # Indicates whether the expectation was satisifed.
    # This is true if:
    # - The matcher was satisified and the expectation is not negated.
    # - The matcher wasn't satisfied and the expectation is negated.
    def satisfied?
      @matched ^ @negated
    end

    # Text that indicates the condition that must be met for the expectation to be satisifed.
    def expected_message
      @negated ? negated_message : message
    end

    # Text that indicates what the outcome was.
    def actual_message
      @matched ? message : negated_message
    end

    # Describes the condition that must be met for the matcher to be satisifed.
    private abstract def message : String

    # Describes the condition under which the matcher won't be satisifed.
    private abstract def negated_message : String
  end
end
