require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a set has a specified number of elements.
  # The set's `#size` method is used for this check.
  struct SizeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the partial given to it.
    def match(partial, negated = false)
      actual = partial.actual.size
      values = ExpectedActual.new(expected, label, actual, partial.label)
      MatchData.new(actual == expected, values)
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
        "#{@values.actual_label} has #{@values.expected_label} elements"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not have #{@values.expected_label} elements"
      end
    end
  end
end
