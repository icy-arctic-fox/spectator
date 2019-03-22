require "./matcher"

module Spectator::Matchers
  # Matcher that tests a value is of a specified type.
  # The values are compared with the `Object#is_a?` method.
  struct TypeMatcher(Expected) < Matcher
    # Textual representation of what the matcher expects.
    # The `Expected` type param will be used to populate the label.
    def label
      Expected.to_s
    end

    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      actual.is_a?(Expected)
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      MatchData(Expected, typeof(actual)).new(match?(actual), partial.label)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @actual_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          expected: NegatableMatchDataValue.new(ExpectedType),
          actual:   ActualType,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} is a #{ExpectedType}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} is not a #{ExpectedType}"
      end
    end
  end
end
