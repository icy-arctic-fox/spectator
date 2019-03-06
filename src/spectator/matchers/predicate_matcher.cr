require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more predicates (methods ending in '?').
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the '?') to test.
  struct PredicateMatcher(ExpectedType) < Matcher
    # Textual representation of what the matcher expects.
    # Constructs the label from the type parameters.
    def label
      {{ExpectedType.keys.splat.stringify}}
    end

    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(values)
      # Test each predicate and immediately return false if one is false.
      {% for attribute in ExpectedType.keys %}
      return false unless values[{{attribute.symbolize}}]
      {% end %}

      # All checks passed if this point is reached.
      true
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial) : MatchData
      values = snapshot_values(partial.actual)
      MatchData.new(match?(values), values, partial.label)
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned,
    # with each key being the attribute.
    private def snapshot_values(actual)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: actual.{{attribute}}?,
        {% end %}
      }
      {% end %}
    end

    # Match data specific to this matcher.
    private struct MatchData(ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ActualType, @actual_label : String)
        super(matched)
      end

      # Information about the match.
      getter values

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} is " + {{ActualType.keys.splat.stringify}}
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} is not " + {{ActualType.keys.splat.stringify}}
      end
    end
  end
end
