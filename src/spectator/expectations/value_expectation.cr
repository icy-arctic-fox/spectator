require "./expectation"

module Spectator::Expectations
  class ValueExpectation(ActualType, ExpectedType)
    include Expectation

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
