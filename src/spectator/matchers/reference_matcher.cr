require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether two references are the same.
  # The values are compared with the `Reference#same?` method.
  struct ReferenceMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is #{expected.label}"
    end

    # Checks whether the matcher is satisifed with the expression given to it.
    private def match?(actual : TestExpression(T)) : Bool forall T
      expected.value.same?(actual.value)
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is not #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} is #{expected.label}"
    end
  end
end
