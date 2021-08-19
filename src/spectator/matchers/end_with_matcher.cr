require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, ends with a value.
  # The `ends_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Indexable` and the `last` value is compared against.
  struct EndWithMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : Value(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "ends with #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      value = actual.value
      if value.is_a?(String) || value.responds_to?(:ends_with?)
        match_ends_with(value, actual.label)
      else
        match_last(value, actual.label)
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      value = actual.value
      if value.is_a?(String) || value.responds_to?(:ends_with?)
        negated_match_ends_with(value, actual.label)
      else
        negated_match_last(value, actual.label)
      end
    end

    # Checks whether the actual value ends with the expected value.
    # This method expects (and uses) the `#ends_with?` method on the value.
    private def match_ends_with(actual_value, actual_label)
      if actual_value.ends_with?(expected.value)
        SuccessfulMatchData.new(match_data_description(actual_label))
      else
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} does not end with #{expected.label} (using #ends_with?)",
          expected: expected.value.inspect,
          actual: actual_value.inspect
        )
      end
    end

    # Checks whether the last element of the value is the expected value.
    # This method expects that the actual value is a set (enumerable).
    private def match_last(actual_value, actual_label)
      list = actual_value.to_a
      last = list.last

      if expected.value === last
        SuccessfulMatchData.new(match_data_description(actual_label))
      else
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} does not end with #{expected.label} (using expected === last)",
          expected: expected.value.inspect,
          actual: last.inspect,
          list: list.inspect
        )
      end
    end

    # Checks whether the actual value does not end with the expected value.
    # This method expects (and uses) the `#ends_with?` method on the value.
    private def negated_match_ends_with(actual_value, actual_label)
      if actual_value.ends_with?(expected.value)
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} ends with #{expected.label} (using #ends_with?)",
          expected: "Not #{expected.value.inspect}",
          actual: actual_value.inspect
        )
      else
        SuccessfulMatchData.new(match_data_description(actual_label))
      end
    end

    # Checks whether the last element of the value is not the expected value.
    # This method expects that the actual value is a set (enumerable).
    private def negated_match_last(actual_value, actual_label)
      list = actual_value.to_a
      last = list.last

      if expected.value === last
        FailedMatchData.new(match_data_description(actual_label), "#{actual_label} ends with #{expected.label} (using expected === last)",
          expected: "Not #{expected.value.inspect}",
          actual: last.inspect,
          list: list.inspect
        )
      else
        SuccessfulMatchData.new(match_data_description(actual_label))
      end
    end
  end
end
