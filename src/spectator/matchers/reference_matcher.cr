require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether two references are the same.
  # The values are compared with the `Reference#same?` method.
  struct ReferenceMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value.same?(actual.value)
    end

    def description
      "is #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is not #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is #{expected.label}"
    end
  end
end
