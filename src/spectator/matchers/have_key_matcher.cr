require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a `Hash` (or similar type) has a given key.
  # The set is checked with the `has_key?` method.
  struct HaveKeyMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "has key #{expected.label}"
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:has_key?)

      actual_value.has_key?(expected.value)
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} does not have key #{expected.label}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} has key #{expected.label}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      actual_value = actual.value
      set = actual_value.responds_to?(:keys) ? actual_value.keys : actual_value
      {
        key:    expected.value.inspect,
        actual: set.inspect,
      }
    end

    private def unexpected(value, label)
      raise "#{label} is not hash-like (must respond to `#has_key?`). #{label}: #{value.inspect}"
    end
  end
end
