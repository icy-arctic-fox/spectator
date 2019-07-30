require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more "has" predicates
  # (methods ending in '?' and starting with 'has_').
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the '?' and 'has_' prefix) to test.
  # Each value is a a `Tuple` of arguments to pass to the predicate method.
  struct HavePredicateMatcher(ExpectedType) < ValueMatcher(ExpectedType)
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
    def match(partial, negated = false)
      values = snapshot_values(partial.actual)
      MatchData.new(match?(values), values, partial.label, label)
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned,
    # with each key being the attribute.
    private def snapshot_values(actual)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: actual.has_{{attribute}}?(*@expected[{{attribute.symbolize}}]),
        {% end %}
      }
      {% end %}
    end

    # Match data specific to this matcher.
    private struct MatchData(ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @named_tuple : ActualType, @actual_label : String, @expected_label : String)
        super(matched)
      end

      # Information about the match.
      getter named_tuple

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} has #{@expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} does not have #{@expected_label}"
      end
    end
  end
end
