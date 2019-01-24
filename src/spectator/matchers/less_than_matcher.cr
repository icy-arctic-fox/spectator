require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is less than another.
  # The values are compared with the `<` operator.
  struct LessThanMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial : Expectations::ValueExpectationPartial(ActualType)) : Bool forall ActualType
      partial.actual < expected
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to be less than #{label} (using <)"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to not be less than #{label} (using <)"
    end
  end
end
