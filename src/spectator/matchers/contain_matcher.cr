require "./matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, contains one or more values.
  # The values are checked with the `includes?` method.
  struct ContainMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : Value(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "contains #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:includes?)

      missing = expected.value.reject do |item|
        actual_value.includes?(item)
      end

      if missing.empty?
        # Contents are present.
        SuccessfulMatchData.new(match_data_description(actual))
      else
        # Content is missing.
        FailedMatchData.new(match_data_description(actual), "#{actual.label} does not contain #{expected.label}",
          expected: expected.value.inspect,
          actual: actual_value.inspect,
          missing: missing.inspect,
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:includes?)

      satisfied = expected.value.any? do |item|
        actual_value.includes?(item)
      end

      if satisfied
        # Contents are present.
        FailedMatchData.new(match_data_description(actual), "#{actual.label} contains #{expected.label}",
          expected: "Not #{expected.value.inspect}",
          actual: actual_value.inspect
        )
      else
        # Content is missing.
        SuccessfulMatchData.new(match_data_description(actual))
      end
    end

    private def unexpected(value, label)
      raise "#{label} is not a collection (must respond to `#includes?`). #{label}: #{value.inspect}"
    end
  end
end
