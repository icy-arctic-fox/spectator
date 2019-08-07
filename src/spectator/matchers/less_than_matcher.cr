require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is less than another.
  # The values are compared with the < operator.
  struct LessThanMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual.value < expected.value
    end

    def description
      "less than #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is greater than or equal to #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is less than #{expected.label}"
    end

    private def values(actual)
      [
        LabeledValue.new("< #{expected.value.inspect}", "expected"),
        LabeledValue.new(actual.value.inspect, "actual"),
      ]
    end

    private def negated_values(actual)
      [
        LabeledValue.new(">= #{expected.value.inspect}", "expected"),
        LabeledValue.new(actual.value.inspect, "actual"),
      ]
    end
  end
end
