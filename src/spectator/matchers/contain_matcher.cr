require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, contains one or more values.
  # The values are checked with the `includes?` method.
  struct ContainMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value.all? do |item|
        actual.value.includes?(item)
      end
    end

    def description
      "contains #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not match #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} contains #{expected.label}"
    end

    private def values(actual) : Array(LabeledValue)
      [
        LabeledValue.new(expected.value.to_s, "subset"),
        LabeledValue.new(actual.value.to_s, "superset"),
      ]
    end
  end
end
