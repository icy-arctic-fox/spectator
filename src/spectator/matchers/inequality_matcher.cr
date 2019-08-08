require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether two values do not equal each other.
  # The values are compared with the != operator.
  struct InequalityMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value != actual.value
    end

    def description
      "is not equal to #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is equal to #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is not equal to #{expected.label}"
    end

    private def values(actual)
      {
        expected: "Not #{expected.value.inspect}",
        actual:   actual.value.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: expected.value.inspect,
        actual:   actual.value.inspect,
      }
    end
  end
end
