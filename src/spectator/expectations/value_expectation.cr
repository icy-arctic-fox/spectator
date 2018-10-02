require "./expectation"

module Spectator::Expectations
  class ValueExpectation(ActualType, ExpectedType) < Expectation
    def initialize(negated,
                   @partial : ValueExpectationPartial(ActualType),
                   @matcher : ValueMatcher(ExpectedType))
      super(negated)
    end

    def eval : Bool
      @matcher.match?(@partial) ^ negated?
    end

    def message : String
      negated? ? @matcher.negated_message(@partial) : @matcher.message(@partial)
    end
  end
end
