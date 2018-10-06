require "./value_matcher"

module Spectator::Matchers
  struct EqualityMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    def match?(partial : Expectations::ValueExpectationPartial(ActualType)) : Bool forall ActualType
      partial.actual == expected
    end

    def message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to equal #{label} (using ==)"
    end

    def negated_message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to not equal #{label} (using ==)"
    end
  end
end
