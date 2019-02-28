require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether two values equal each other.
  # The values are compared with the == operator.
  struct EqualityMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      partial.actual == expected
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial) : MatchData
      actual = partial.actual
      matched = actual == expected
      MatchData.new(matched, expected, actual, partial.label, label)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to equal #{label} (using ==)"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not equal #{label} (using ==)"
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @expected : ExpectedType, @actual : ActualType, @expected_label : String, @actual_label : String)
        super(matched)
      end

      # Information about the match.
      def values
        {
          expected: @expected,
          actual:   @actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@expected_label} is #{@actual_label} (using ==)"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@expected_label} is not #{@actual_label} (using ==)"
      end
    end
  end
end
