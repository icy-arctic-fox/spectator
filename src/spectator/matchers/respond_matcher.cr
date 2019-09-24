require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests that a type responds to a method call.
  # The instance is tested with the `responds_to?` method.
  # The `ExpectedType` type param should be a `NamedTuple`,
  # with each key being the method to check and the value is ignored.
  struct RespondMatcher(ExpectedType) < Matcher
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "responds to #{label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not respond to #{label}", **values(snapshot))
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} responds to #{label}", **values(snapshot))
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

    # Checks if all results from the snapshot are satisified.
    private def match?(snapshot)
      # The snapshot did the hard work.
      # Here just check if all values are true.
      snapshot.values.all?
    end

    # Produces the tuple for the failed match data from a snapshot of the results.
    private def values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: snapshot[{{attribute.symbolize}}].inspect,
        {% end %}
      }
      {% end %}
    end

    # Generated, user-friendly, string for the expected value.
    private def label
      # Prefix every method name with # and join them with commas.
      {{ExpectedType.keys.map { |e| "##{e}".id }.splat.stringify}}
    end
  end
end
