require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a `Hash` (or similar type) has a given value.
  # The set is checked with the `has_value?` method.
  struct HaveValueMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual.value.has_value?(expected.value)
    end

    def description
      "has value #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not have value #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} has value #{expected.label}"
    end

    private def values(actual)
      actual_value = actual.value
      set = actual_value.responds_to?(:values) ? actual_value.values : actual_value
      {
        value:  expected.value.inspect,
        actual: set.inspect,
      }
    end
  end
end
