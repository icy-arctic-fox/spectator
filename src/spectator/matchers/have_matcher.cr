require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches a value.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until `===` is true.
  struct HaveMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      actual = partial.actual
      if actual.is_a?(String)
        match_string?(actual)
      else
        match_enumerable?(actual)
      end
    end

    # Checks if a `String` matches the expected value.
    # The `includes?` method is used for this check.
    private def match_string?(actual)
      actual.includes?(expected)
    end

    # Checks if an `Enumerable` matches the expected value.
    # The `===` operator is used on every item.
    private def match_enumerable?(actual)
      actual.each do |item|
        return true if expected === item
      end
      false
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to include #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not include #{label}"
    end
  end
end
