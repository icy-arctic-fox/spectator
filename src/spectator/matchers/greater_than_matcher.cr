require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is greater than another.
  # The values are compared with the > operator.
  struct GreaterThanMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual.value > expected.value
    end

    def description
      "greater than #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is less than or equal to #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is greater than #{expected.label}"
    end

    private def values(actual)
      [
        LabeledValue.new("> #{expected.value}", "expected"),
        LabeledValue.new(actual.value.to_s, "actual")
      ]
    end

    private def negated_values(actual)
      [
        LabeledValue.new("<= #{expected.value}", "expected"),
        LabeledValue.new(actual.value.to_s, "actual")
      ]
    end
  end
end
