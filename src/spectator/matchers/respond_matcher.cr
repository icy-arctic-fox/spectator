require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests that a type responds to a method call.
  # The instance is tested with the `responds_to?` method.
  # The `ExpectedType` type param should be a `NamedTuple`,
  # with each key being the method to check and the value is ignored.
  struct RespondMatcher(ExpectedType) < Matcher
    def description
      "responds to #{label}"
    end

    private def label
      # Prefix every method name with # and join them with commas.
      {{ExpectedType.keys.map { |e| "##{e}".id }.splat.stringify}}
    end

    def match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not respond to #{label}", **snapshot)
      end
    end

    def negated_match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} responds to #{label}", **snapshot)
      else
        SuccessfulMatchData.new
      end
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned, with each key being the attribute.
    private def snapshot_values(object)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: object.responds_to?({{attribute.symbolize}}),
        {% end %}
      }
      {% end %}
    end

    private def match?(snapshot)
      # The snapshot did the hard work.
      # Here just check if all values are true.
      snapshot.values.all?
    end
  end
end
