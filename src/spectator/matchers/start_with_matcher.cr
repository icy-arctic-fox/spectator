# Checks whether the last element of the value is the expected value.
# This method expects that the actual value is a set (enumerable).require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, starts with a value.
  # The `starts_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Enumerable` and the `first` value is compared against.
  struct StartWithMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : Value(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "starts with #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      value = actual.value
      if value.is_a?(String) || value.responds_to?(:starts_with?)
        match_starts_with(value, actual.label)
      else
        match_first(value, actual.label)
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      value = actual.value
      if value.is_a?(String) || value.responds_to?(:starts_with?)
        negated_match_starts_with(value, actual.label)
      else
        negated_match_first(value, actual.label)
      end
    end

    # Checks whether the actual value starts with the expected value.
    # This method expects (and uses) the `#starts_with?` method on the value.
    private def match_starts_with(actual_value, actual_label)
      if actual_value.starts_with?(expected.value)
        SuccessfulMatchData.new(match_data_description(actual_label))
      else
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} does not start with #{expected.label} (using #starts_with?)",
          expected: expected.value.inspect,
          actual: actual_value.inspect
        )
      end
    end

    # Checks whether the first element of the value is the expected value.
    # This method expects that the actual value is a set (enumerable).
    private def match_first(actual_value, actual_label)
      list = actual_value.to_a
      first = list.first

      if expected.value === first
        SuccessfulMatchData.new(match_data_description(actual_label))
      else
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} does not start with #{expected.label} (using expected === first)",
          expected: expected.value.inspect,
          actual: first.inspect,
          list: list.inspect
        )
      end
    end

    # Checks whether the actual value does not start with the expected value.
    # This method expects (and uses) the `#starts_with?` method on the value.
    private def negated_match_starts_with(actual_value, actual_label)
      if actual_value.starts_with?(expected.value)
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} starts with #{expected.label} (using #starts_with?)",
          expected: "Not #{expected.value.inspect}",
          actual: actual_value.inspect
        )
      else
        SuccessfulMatchData.new(match_data_description(actual_label))
      end
    end

    # Checks whether the first element of the value is not the expected value.
    # This method expects that the actual value is a set (enumerable).
    private def negated_match_first(actual_value, actual_label)
      list = actual_value.to_a
      first = list.first

      if expected.value === first
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} starts with #{expected.label} (using expected === first)",
          expected: "Not #{expected.value.inspect}",
          actual: first.inspect,
          list: list.inspect
        )
      else
        SuccessfulMatchData.new(match_data_description(actual_label))
      end
    end
  end
end
