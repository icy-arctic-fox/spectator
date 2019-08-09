require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more "has" predicates
  # (methods ending in '?' and starting with 'has_').
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the '?' and 'has_' prefix) to test.
  # Each value is a a `Tuple` of arguments to pass to the predicate method.
  struct HavePredicateMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "has #{expected.label}"
    end

    def match(actual)
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not have #{expected.label}", **snapshot)
      end
    end

    def negated_match(actual)
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} has #{expected.label}", **snapshot)
      else
        SuccessfulMatchData.new
      end
    end

    private def failure_message(actual)
      "#{actual.label} does not have #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} has #{expected.label}"
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned, with each key being the attribute.
    private def snapshot_values(object)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: object.has_{{attribute}}?(*@expected.value[{{attribute.symbolize}}]),
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
