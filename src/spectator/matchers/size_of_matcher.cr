require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a set has the same number of elements as another set.
  # The set's `#size` method is used for this check.
  struct SizeOfMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual.size
      size = expected.size
      values = ExpectedActual.new(size, label, actual, partial.label)
      MatchData.new(actual == size, values)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          expected: NegatableMatchDataValue.new(@values.expected),
          actual:   @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} has the same number of elements as #{@values.expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} has a different number of elements than #{@values.expected_label}"
      end
    end
  end
end
