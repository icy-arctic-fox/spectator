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

    def match(actual)
      if actual.value.responds_to?(:starts_with?)
        match_starts_with(actual)
      else
        match_first(actual)
      end
    end

    private def match_starts_with(actual)
      if actual.value.starts_with?(expected.value)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not start with #{expected.label} (using #starts_with?)",
          expected: expected.value.inspect,
          actual: actual.value.inspect
        )
      end
    end

    private def match_first(value, actual)
      first = list.first

      if expected.value === first
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not start with #{expected.label} (using expected === first)",
          expected: expected.value,
          actual: first,
          list: list
        )
      end
    end

    def negated_match(actual)
      if actual.value.responds_to?(:starts_with?)
        negated_match_starts_with(actual)
      else
        negated_match_first(actual)
      end
    end

    private def negated_match_starts_with(actual)
      if actual.value.starts_with?(expected.value)
        FailedMatchData.new("#{actual.label} starts with #{expected.label} (using #starts_with?)",
          expected: expected.value.inspect,
          actual: actual.value.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end

    private def negated_match_first(actual)
      list = actual.value.to_a
      first = list.first

      if expected.value === first
        FailedMatchData.new("#{actual.label} starts with #{expected.label} (using expected === first)",
          expected: expected.value,
          actual: first,
          list: list
        )
      else
        SuccessfulMatchData.new
      end
    end
  end
end
