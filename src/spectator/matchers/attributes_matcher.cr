require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests that multiple attributes match specified conditions.
  # The attributes are tested with the === operator.
  # The `ExpectedType` type param should be a `NamedTuple`.
  struct AttributesMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      # Test each attribute and immediately return false if a comparison fails.
      {% for attribute in ExpectedType.keys %}
      return false unless expected[{{attribute.symbolize}}] === actual[{{attribute.symbolize}}]
      {% end %}

      # All checks passed if this point is reached.
      true
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    def match(partial, negated = false)
      actual_values = snapshot_values(partial.actual)
      values = ExpectedActual.new(expected, label, actual_values, partial.label)
      MatchData.new(match?(actual_values), values)
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned,
    # with each key being the attribute.
    private def snapshot_values(actual)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: actual.{{attribute}},
        {% end %}
      }
      {% end %}
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {% begin %}
        {
          {% for attribute in ExpectedType.keys %}
          {{"expected " + attribute.stringify}}: NegatableMatchDataValue.new(@values.expected[{{attribute.symbolize}}]),
          {{"actual " + attribute.stringify}}:   @values.actual[{{attribute.symbolize}}],
          {% end %}
        }
        {% end %}
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} has attributes #{@values.expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not have attributes #{@values.expected_label}"
      end
    end
  end
end
