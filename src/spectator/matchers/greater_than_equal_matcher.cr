require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is greater than or equal to another.
  # The values are compared with the `>=` operator.
  struct GreaterThanEqualMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial) : Bool
      partial.actual >= expected
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial) : String
      "Expected #{partial.label} to be greater than or equal to #{label} (using >=)"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial) : String
      "Expected #{partial.label} to not be greater than or equal to #{label} (using >=)"
    end
  end
end
