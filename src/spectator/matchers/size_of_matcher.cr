require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a set has the same number of elements as another set.
  # The set's `#size` method is used for this check.
  struct SizeOfMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is the same size as #{expected.label}"
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:size?)

      expected.value.size == actual_value.size
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is not the same size as #{expected.label}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} is the same size as #{expected.label}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        expected: expected.value.size.inspect,
        actual:   actual.value.size.inspect,
      }
    end

    # Additional information about the match failure when negated.
    # The return value is a NamedTuple with Strings for each value.
    private def negated_values(actual)
      {
        expected: "Not #{expected.value.size.inspect}",
        actual:   actual.value.size.inspect,
      }
    end

    private def unexpected(value, label)
      raise "#{label} must respond to `#size`. #{label}: #{value.inspect}"
    end
  end
end
