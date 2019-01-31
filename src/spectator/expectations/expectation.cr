module Spectator::Expectations
  class Expectation
    # Populates the base portiion of the expectation with values.
    # The `matched` flag should be true if the matcher is satisfied with the partial.
    # The `negated` flag should be true if the expectation is inverted.
    # These options are mutually-exclusive in this context.
    # Don't flip the value of `matched` because `negated` is true.
    # The `partial` and the `matcher` arguments should reference
    # the actual and expected result respectively.
    def initialize(@matched : Bool, @negated : Bool,
      @partial : ExpectationPartial, @matcher : Matchers::Matcher)
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
      satisfied? ? message : negated_message
    end

    # Describes the condition that must be met for the expectation to be satisifed.
    private def message
      @matcher.message(@partial)
    end

    # Describes the condition under which the expectation won't be satisifed.
    private def negated_message
      @matcher.negated_message(@partial)
    end
  end
end
