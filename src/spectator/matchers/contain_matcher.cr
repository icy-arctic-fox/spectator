require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, contains one or more values.
  # The values are checked with the `includes?` method.
  struct ContainMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Checks whether the matcher is satisifed with the expression given to it.
    private def match?(actual)
      expected.value.all? do |item|
        actual.value.includes?(item)
      end
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description
      "contains #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual)
      "#{actual.label} does not match #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual)
      "#{actual.label} contains #{expected.label}"
    end
    
    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        subset:   expected.value.inspect,
        superset: actual.value.inspect,
      }
    end
  end
end
