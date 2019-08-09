require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more predicates (methods ending in '?').
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the '?') to test.
  # Each value is a a `Tuple` of arguments to pass to the predicate method.
  struct PredicateMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "is #{expected.label}"
    end

    def match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} is not #{expected.label}", **values(snapshot))
      end
    end

    def negated_match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} is #{expected.label}", **values(snapshot))
      else
        SuccessfulMatchData.new
      end
    end

    private def failure_message(actual)
      "#{actual.label} is not #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is #{expected.label}"
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned, with each key being the attribute.
    private def snapshot_values(object)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: object.{{attribute}}?(*@expected.value[{{attribute.symbolize}}]),
        {% end %}
      }
      {% end %}
    end

    private def values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: snapshot[{{attribute.symbolize}}].inspect,
        {% end %}
      }
      {% end %}
    end

    private def match?(snapshot)
      # Test each predicate and immediately return false if one is false.
      {% for attribute in ExpectedType.keys %}
      return false unless snapshot[{{attribute.symbolize}}]
      {% end %}

      # All checks passed if this point is reached.
      true
    end
  end
end
