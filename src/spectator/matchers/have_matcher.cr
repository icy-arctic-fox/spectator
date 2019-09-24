require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches one or more values.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until === is true.
  struct HaveMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "includes #{expected.label}"
    end

    # Checks whether the matcher is satisifed with the expression given to it.
    private def match?(actual : TestExpression(T)) : Bool forall T
      if (value = actual.value).is_a?(String)
        match_string?(value)
      else
        match_enumerable?(value)
      end
    end

    # Checks if a `String` matches the expected values.
    # The `includes?` method is used for this check.
    private def match_string?(value)
      expected.value.all? do |item|
        value.includes?(item)
      end
    end

    # Checks if an `Enumerable` matches the expected values.
    # The `===` operator is used on every item.
    private def match_enumerable?(value)
      array = value.to_a
      expected.value.all? do |item|
        array.any? do |element|
          item === element
        end
      end
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} does not include #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} includes #{expected.label}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        subset:   expected.value.inspect,
        superset: actual.value.inspect,
      }
    end
  end
end
