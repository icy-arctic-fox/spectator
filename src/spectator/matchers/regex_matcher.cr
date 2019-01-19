require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value matches a regular expression.
  # The value is compared with the `=~` operator.
  struct RegexMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial : Expectations::ValueExpectationPartial(ActualType)) : Bool forall ActualType
      !!(partial.actual =~ expected)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to match #{label} (using =~)"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to not match #{label} (using =~)"
    end
  end
end
