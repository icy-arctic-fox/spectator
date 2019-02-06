require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a `Hash` (or similar type) has a given value.
  # The set is checked with the `has_value?` method.
  struct HaveValueMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      partial.actual.has_value?(expected)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to have value #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not have value #{label}"
    end
  end
end
