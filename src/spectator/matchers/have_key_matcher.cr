require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a `Hash` (or similar type) has a given key.
  # The set is checked with the `has_key?` method.
  struct HaveKeyMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual.value.has_key?(expected.value)
    end

    def description
      "has key #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not have key #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} has key #{expected.label}"
    end

    private def values(actual)
      actual_value = actual.value
      set = actual_value.responds_to?(:keys) ? actual_value.keys : actual_value
      {
        key:    expected.value.inspect,
        actual: set.inspect,
      }
    end
  end
end
