require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is greater than or equal to another.
  # The values are compared with the >= operator.
  struct GreaterThanEqualMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual.value >= expected.value
    end

    def description
      "greater than or equal to #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is less than #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is greater than or equal to #{expected.label}"
    end

    private def values(actual)
      {
        expected: ">= #{expected.value.inspect}",
        actual:   actual.value.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: "< #{expected.value.inspect}",
        actual:   actual.value.inspect,
      }
    end
  end
end
