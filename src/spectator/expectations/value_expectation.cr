require "./expectation"

module Spectator::Expectations
  # Expectation that operates on values.
  # There is a primary "actual" value that the SUT produced.
  # A matcher is used on that value to determine whether it satisfies some criteria.
  class ValueExpectation(ActualType) < Expectation
    # Creates the expectation.
    # The `matched` flag should be true if the matcher is satisfied with the partial.
    # The `negated` flag should be true if the expectation is inverted.
    # See `Expectation#initialize` for details on these two arguments.
    # The `partial` and the `matcher` arguments should reference
    # the actual and expected value with matcher respectively.
    def initialize(matched, negated,
                   @partial : ValueExpectationPartial(ActualType),
                   @matcher : Matchers::Matcher)
      super(matched, negated)
    end

    # Describes the condition that must be met for the expectation to be satisifed.
    private def message : String
      @matcher.message(@partial)
    end

    # Describes the condition under which the expectation won't be satisifed.
    private def negated_message : String
      @matcher.negated_message(@partial)
    end
  end
end
