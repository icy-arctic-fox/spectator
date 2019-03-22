require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether one value is greater than another.
  # The values are compared with the > operator.
  struct GreaterThanMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      actual > expected
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      values = ExpectedActual.new(partial, self)
      MatchData.new(match?(values.actual), values)
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
          expected: NegatablePrefixedMatchDataValue.new(">", "<=", @values.expected),
          actual:   PrefixedMatchDataValue.new(actual_operator, @values.actual),
        }
      end

      # Textual operator for the actual value.
      private def actual_operator
        matched? ? ">" : "<="
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} is greater than #{@values.expected_label} (using >)"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} is less than or equal to #{@values.expected_label} (using >)"
      end
    end
  end
end
