require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether two values semantically equal each other.
  # The values are compared with the `===` operator.
  struct CaseMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      expected === partial.actual
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to semantically equal #{label} (using ===)"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not semantically equal #{label} (using ===)"
    end
  end
end
