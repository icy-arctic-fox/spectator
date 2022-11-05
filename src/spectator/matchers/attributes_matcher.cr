require "../value"
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
    # Stand-in for undefined methods on types.
    private module Undefined
      extend self

      # Text displayed when a method is undefined.
      def inspect(io : IO) : Nil
        io << "<Method undefined>"
      end
    end

    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : Value(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "has attributes #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), "#{actual.label} does not have attributes #{expected.label}", values(snapshot).to_a)
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      snapshot = snapshot_values(actual.value)
      if match?(snapshot)
        FailedMatchData.new(match_data_description(actual), "#{actual.label} has attributes #{expected.label}", negated_values(snapshot).to_a)
      else
        SuccessfulMatchData.new(match_data_description(actual))
      end
    end

    # Captures all of the actual values.
    # A `NamedTuple` is returned, with each key being the attribute.
    private def snapshot_values(object)
      {% begin %}
      {
        {% for attribute in ExpectedType.keys %}
        {{attribute}}: object.responds_to?({{attribute.symbolize}}) ? object.{{attribute}} : Undefined,
        {% end %}
      }
      {% end %}
    end

    # Checks if all attributes from the snapshot of them are satisfied.
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
