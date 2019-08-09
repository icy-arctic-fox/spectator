require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, starts with a value.
  # The `starts_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Enumerable` and the `first` value is compared against.
  struct StartWithMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "starts with #{expected.label}"
    end

    def match(actual : TestExpression(T)) : MatchData forall T
      if (value = actual.value).responds_to?(:starts_with?)
        match_starts_with(value, actual.label)
      else
        match_first(value, actual.label)
      end
    end

    private def match_starts_with(actual_value, actual_label)
      if actual_value.starts_with?(expected.value)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual_label} does not start with #{expected.label} (using #starts_with?)",
          expected: expected.value.inspect,
          actual: actual_value.inspect
        )
      end
    end

    private def match_first(actual_value, actual_label)
      list = actual_value.to_a
      first = list.first

      if expected.value === first
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual_label} does not start with #{expected.label} (using expected === first)",
          expected: expected.value.inspect,
          actual: first.inspect,
          list: list.inspect
        )
      end
    end

    def negated_match(actual : TestExpression(T)) : MatchData forall T
      if (value = actual.value).responds_to?(:starts_with?)
        negated_match_starts_with(value, actual.label)
      else
        negated_match_first(value, actual.label)
      end
    end

    private def negated_match_starts_with(actual_value, actual_label)
      if actual_value.starts_with?(expected.value)
        FailedMatchData.new("#{actual_label} starts with #{expected.label} (using #starts_with?)",
          expected: expected.value.inspect,
          actual: actual_value.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end

    private def negated_match_first(actual_value, actual_label)
      list = actual_value.to_a
      first = list.first

      if expected.value === first
        FailedMatchData.new("#{actual_label} starts with #{expected.label} (using expected === first)",
          expected: expected.value.inspect,
          actual: first.inspect,
          list: list.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end
  end
end
