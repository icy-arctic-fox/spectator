require "./matcher"

module Spectator::Matchers
  # Matcher that tests whether a collection is empty.
  # The values are checked with the `empty?` method.
  struct EmptyMatcher < Matcher
    # Textual representation of what the matcher expects.
    def label
      "empty?"
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      matched = actual.empty?
      MatchData.new(matched, actual, partial.label)
    end

    # Match data specific to this matcher.
    private struct MatchData(T) < MatchData
      # Creates the match data.
      def initialize(matched, @actual : T, @actual_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          expected: NegatableMatchDataValue.new([] of Nil),
          actual:   @actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} is empty"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} is not empty"
      end
    end
  end
end
