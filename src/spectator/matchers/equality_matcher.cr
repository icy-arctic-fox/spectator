require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether two values equal each other.
  # The values are compared with the == operator.
  struct EqualityMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial) : MatchData
      actual = partial.actual
      matched = actual == expected
      values = ExpectedActual.new(expected, label, actual, partial.label)
      MatchData.new(matched, values)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def values
        {
          expected: @values.expected,
          actual:   @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.expected_label} is #{@values.actual_label} (using ==)"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.expected_label} is not #{@values.actual_label} (using ==)"
      end
    end
  end
end
