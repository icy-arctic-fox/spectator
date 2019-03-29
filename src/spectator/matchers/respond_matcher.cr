require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests that a type responds to a method call.
  # The instance is tested with the `responds_to?` method.
  # The `ExpectedType` type param should be a `NamedTuple`,
  # with each key being the method to check and the value is ignored.
  struct RespondMatcher(ExpectedType) < Matcher
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      # The snapshot did the hard work.
      # Here just check if all values are true.
      actual.values.all?
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      values = snapshot_values(partial.actual)
      MatchData.new(match?(values), values, partial.label, label)
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned,
    # with each key being the attribute.
    private def snapshot_values(actual)
      {% begin %}
      {
        {% for method in ExpectedType.keys %}
        {{method.stringify}}: actual.responds_to?({{method.symbolize}}),
        {% end %}
      }
      {% end %}
    end

    # Textual representation of what the matcher expects.
    def label
      # Prefix every method name with # and join them with commas.
      {{ExpectedType.keys.map { |e| "##{e}".id }.splat.stringify}}
    end

    # Match data specific to this matcher.
    private struct MatchData(ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @actual : ActualType, @actual_label : String, @expected_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {% begin %}
        {
          {% for method in ActualType.keys %}
          {{"responds to #" + method.stringify}}: @actual[{{method.symbolize}}],
          {% end %}
        }
        {% end %}
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} responds to #{@expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} does not respond to #{@expected_label}"
      end
    end
  end
end
