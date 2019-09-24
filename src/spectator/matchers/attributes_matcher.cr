require "../test_value"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests that multiple attributes match specified conditions.
  # The attributes are tested with the === operator.
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is the attribute/method name,
  # and the corresponding value is the expected value to match against.
  struct AttributesMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "has attributes #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not have attributes #{expected.label}", **values(snapshot))
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new("#{actual.label} has attributes #{expected.label}", **negated_values(snapshot))
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
        {{attribute}}: object.{{attribute}},
        {% end %}
      }
      {% end %}
    end

    # Checks if all attributes from the snapshot of them are satisified.
    private def match?(snapshot)
      # Test that every attribute has the expected value.
      {% for attribute in ExpectedType.keys %}
      return false unless expected.value[{{attribute.symbolize}}] === snapshot[{{attribute.symbolize}}]
      {% end %}

      # At this point, none of the checks failed, so the match was successful.
      true
    end

    # Produces the tuple for the failed match data from a snapshot of the attributes.
    private def values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{"expected " + attribute.stringify}}: expected.value[{{attribute.symbolize}}].inspect,
        {{"actual " + attribute.stringify}}:   snapshot[{{attribute.symbolize}}].inspect,
        {% end %}
      }
      {% end %}
    end

    # Produces the tuple for the failed negated match data from a snapshot of the attributes.
    private def negated_values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{"expected " + attribute.stringify}}: "Not #{expected.value[{{attribute.symbolize}}].inspect}",
        {{"actual " + attribute.stringify}}:   snapshot[{{attribute.symbolize}}].inspect,
        {% end %}
      }
      {% end %}
    end
  end
end
