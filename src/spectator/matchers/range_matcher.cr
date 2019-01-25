require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is in a given range or set of values.
  # The `#includes?` method is used for this check.
  # Typically this matcher uses a `Range`,
  # but any type that implements the `#includes?` method is supported.
  struct RangeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial : Expectations::ValueExpectationPartial(ActualType)) : Bool forall ActualType
      @expected.includes?(partial.actual)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to be in #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to not be in #{label}"
    end
  end
end
