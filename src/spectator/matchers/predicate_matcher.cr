require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more predicates (methods ending in '?').
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the '?') to test.
  # Each value is a a `Tuple` of arguments to pass to the predicate method.
  struct PredicateMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with a expected values.
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} is not #{expected.label}", **values(snapshot))
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} is #{expected.label}", **values(snapshot))
      else
        SuccessfulMatchData.new
      end
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is not #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
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

    # Checks if all predicate methods from the snapshot of them are satisified.
    private def match?(snapshot)
      # Test each predicate and immediately return false if one is false.
      {% for attribute in ExpectedType.keys %}
      return false unless snapshot[{{attribute.symbolize}}]
      {% end %}

      # All checks passed if this point is reached.
      true
    end

    # Produces the tuple for the failed match data from a snapshot of the predicate methods.
    private def values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: snapshot[{{attribute.symbolize}}].inspect,
        {% end %}
      }
      {% end %}
    end
  end
end
