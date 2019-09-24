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
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "ends with #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      if (value = actual.value).responds_to?(:ends_with?)
        match_ends_with(value, actual.label)
      else
        match_last(value, actual.label)
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      if actual.value.responds_to?(:ends_with?)
        negated_match_ends_with(actual)
      else
        negated_match_last(actual)
      end
    end

    # Checks whether the actual value ends with the expected value.
    # This method expects (and uses) the `#ends_with?` method on the value.
    private def match_ends_with(actual_value, actual_label)
      if actual_value.ends_with?(expected.value)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual_label} does not end with #{expected.label} (using #ends_with?)",
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
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual_label} does not end with #{expected.label} (using expected === last)",
          expected: expected.value.inspect,
          actual: last.inspect,
          list: list.inspect
        )
      end
    end

    # Checks whether the actual value does not end with the expected value.
    # This method expects (and uses) the `#ends_with?` method on the value.
    private def negated_match_ends_with(actual)
      if actual.value.ends_with?(expected.value)
        FailedMatchData.new("#{actual.label} ends with #{expected.label} (using #ends_with?)",
          expected: expected.value.inspect,
          actual: actual.value.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end

    # Checks whether the last element of the value is not the expected value.
    # This method expects that the actual value is a set (enumerable).
    private def negated_match_last(actual)
      list = actual.value.to_a
      last = list.last

      if expected.value === last
        FailedMatchData.new("#{actual.label} ends with #{expected.label} (using expected === last)",
          expected: expected.value.inspect,
          actual: last.inspect,
          list: list.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end
  end
end
