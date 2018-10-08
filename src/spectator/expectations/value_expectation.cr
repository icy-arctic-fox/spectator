require "./expectation"

module Spectator::Expectations
  # Expectation that operates on values.
  # There are two values - the actual and expected.
  # The actual value is what the SUT returned.
  # The expected value is what the test wants to see.
  struct ValueExpectation(ActualType, ExpectedType)
    include Expectation

    # Creates the expectation.
    # This simply takes in the expectation partial and the matcher.
    def initialize(@partial : ValueExpectationPartial(ActualType),
                   @matcher : Matchers::ValueMatcher(ExpectedType))
    end

    # Checks whether the expectation is met.
    def satisfied? : Bool
      @matcher.match?(@partial)
    end

    # Describes the condition that must be met for the expectation to be satisifed.
    def message : String
      @matcher.message(@partial)
    end

    # Describes the condition under which the expectation won't be satisifed.
    def negated_message : String
      @matcher.negated_message(@partial)
    end
  end
end
