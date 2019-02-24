require "./matcher"

module Spectator::Matchers
  # Common matcher that tests whether a value is nil.
  # The `Object#nil?` method is used for this.
  struct NilMatcher < Matcher
    # Creates the matcher.
    def initialize
      super("nil?")
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      matched = actual.nil?
      MatchData.new(matched, actual, partial.label)
    end

    # Match data specific to this matcher.
    private struct MatchData(T) < MatchData
      # Creates the match data.
      def initialize(matched, @actual : T, @expected_label : String)
        super(matched)
      end

      # Information about the match.
      def values
        {
          expected: nil,
          actual:   @actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@expected_label} is nil"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@expected_label} is not nil"
      end
    end
  end
end
