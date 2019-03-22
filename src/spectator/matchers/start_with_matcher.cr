require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, starts with a value.
  # The `starts_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Enumerable` and the `first` value is compared against.
  struct StartWithMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match_starts_with?(actual)
      actual.starts_with?(expected)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    private def match_first?(actual)
      expected === actual
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      values = ExpectedActual.new(partial, self)
      actual = values.actual
      if actual.responds_to?(:starts_with?)
        StartsWithMatchData.new(match_starts_with?(actual), values)
      else
        first = actual.first
        FirstMatchData.new(match_first?(first), values, first)
      end
    end

    # Match data specific to this matcher.
    # This type is used when the actual value responds to `starts_with?`.
    private struct StartsWithMatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          expected: NegatableValue.new(@values.expected),
          actual:   @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} starts with #{@values.expected_label} (using #starts_with?)"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not start with #{@values.expected_label} (using #starts_with?)"
      end
    end

    # Match data specific to this matcher.
    # This type is used when the actual value does not respond to `ends_with?`.
    private struct FirstMatchData(ExpectedType, ActualType, FirstType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType), @first : FirstType)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          expected: @values.expected,
          actual:   @first,
          list:     @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} starts with #{@values.expected_label} (using expected === actual.first)"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not start with #{@values.expected_label} (using expected === actual.first)"
      end
    end
  end
end
