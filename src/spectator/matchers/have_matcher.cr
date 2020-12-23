require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches one or more values.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until === is true.
  struct HaveMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "has #{expected.label}"
    end

    # Entrypoint for the matcher, forwards to the correct method for string or enumerable.
    def match(actual : TestExpression(T)) : MatchData forall T
      if (value = actual.value).is_a?(String)
        match_string(value, actual.label)
      else
        match_enumerable(value, actual.label)
      end
    end

    # Actually performs the test against the expression.
    private def match_enumerable(actual_value, actual_label)
      array = actual_value.to_a
      missing = expected.value.reject do |item|
        array.any? do |element|
          item === element
        end
      end

      if missing.empty?
        # Contents are present.
        SuccessfulMatchData.new(description)
      else
        # Content is missing.
        FailedMatchData.new(description, "#{actual_label} does not have #{expected.label}",
          expected: expected.value.inspect,
          actual: actual_value.inspect,
          missing: missing.inspect,
        )
      end
    end

    # Checks if a `String` matches the expected values.
    # The `includes?` method is used for this check.
    private def match_string(actual_value, actual_label)
      missing = expected.value.reject do |item|
        actual_value.includes?(item)
      end

      if missing.empty?
        SuccessfulMatchData.new(description)
      else
        FailedMatchData.new(description, "#{actual_label} does not have #{expected.label}",
          expected: expected.value.inspect,
          actual: actual_value.inspect,
          missing: missing.inspect,
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      if (value = actual.value).is_a?(String)
        negated_match_string(value, actual.label)
      else
        negated_match_enumerable(value, actual.label)
      end
    end

    # Actually performs the negated test against the expression.
    private def negated_match_enumerable(actual_value, actual_label)
      array = actual_value.to_a
      satisfied = expected.value.any? do |item|
        array.any? do |element|
          item === element
        end
      end

      if satisfied
        # Contents are present.
        FailedMatchData.new(description, "#{actual_label} has #{expected.label}",
          expected: "Not #{expected.value.inspect}",
          actual: actual_value.inspect
        )
      else
        # Content is missing.
        SuccessfulMatchData.new(description)
      end
    end

    # Checks if a `String` doesn't match the expected values.
    # The `includes?` method is used for this check.
    private def negated_match_string(actual_value, actual_label)
      satisfied = expected.value.any? do |item|
        actual_value.includes?(item)
      end

      if satisfied
        SuccessfulMatchData.new(description)
      else
        FailedMatchData.new(description, "#{actual_label} does not have #{expected.label}",
          expected: expected.value.inspect,
          actual: actual_value.inspect,
          missing: missing.inspect,
        )
      end
    end
  end
end
