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
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "has attributes #{expected.label}"
    end

    def match(actual)
      snapshot = snapshot_values(actual.value)
      if matched?(snapshot)
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} does not have attributes #{expected.label}", **values(snapshot))
      end
    end

    def negated_match(actual)
      snapshot = snapshot_values(actual.value)
      if matched?(snapshot)
        FailedMatchData.new("#{actual.label} has attributes #{expected.label}", **values(snapshot))
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

    private def values(snapshot)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{"expected " + attribute.stringify}}: expected.value[{{attribute.symbolize}}]),
        {{"actual " + attribute.stringify}}:   snapshot[{{attribute.symbolize}}],
        {% end %}
      }
      {% end %}
    end
  end
end
