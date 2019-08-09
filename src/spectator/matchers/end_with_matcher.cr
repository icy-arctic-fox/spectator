require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, ends with a value.
  # The `ends_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Indexable` and the `last` value is compared against.
  struct EndWithMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "ends with #{expected.label}"
    end

    def match(actual)
      if (value = actual.value).responds_to?(:ends_with?)
        match_ends_with(value, actual.label)
      else
        match_last(value, actual.label)
      end
    end

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

    def negated_match(actual)
      if actual.value.responds_to?(:ends_with?)
        negated_match_ends_with(actual)
      else
        negated_match_last(actual)
      end
    end

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
