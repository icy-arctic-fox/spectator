require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether two values equal each other.
  # The values are compared with the == operator.
  struct EqualityMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value == actual.value
    end

    def description
      "equals #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not equal #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} equals #{expected.label}"
    end
  end
end
