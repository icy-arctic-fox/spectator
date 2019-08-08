require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a set has a specified number of elements.
  # The set's `#size` method is used for this check.
  struct SizeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value == actual.value.size
    end

    def description
      "has size #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not have #{expected.label} elements"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} has #{expected.label} elements"
    end

    private def values(actual)
      {
        expected: expected.value.inspect,
        actual:   actual.value.size.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: "Not #{expected.value.inspect}",
        actual:   actual.value.size.inspect,
      }
    end
  end
end
