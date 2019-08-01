require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether two values semantically equal each other.
  # The values are compared with the === operator.
  struct CaseMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value === actual.value
    end

    def description
      "matches #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not match #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} matched #{expected.label}"
    end
  end
end
