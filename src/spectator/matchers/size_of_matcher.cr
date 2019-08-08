require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a set has the same number of elements as another set.
  # The set's `#size` method is used for this check.
  struct SizeOfMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value.size == actual.value.size
    end

    def description
      "is the same size as #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is not the same size as #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is the same size as #{expected.label}"
    end

    private def values(actual)
      {
        expected: expected.value.size.inspect,
        actual:   actual.value.size.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: "Not #{expected.value.size.inspect}",
        actual:   actual.value.size.inspect,
      }
    end
  end
end
