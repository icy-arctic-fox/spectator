require "../mocks/stub"
require "../mocks/stubbable"
require "../mocks/stubbed_type"
require "./matcher"

module Spectator::Matchers
  # Matcher that inspects stubbable objects for method calls.
  struct ReceiveMatcher < Matcher
    def initialize(@stub : Stub)
    end

    def initialize(expected : Expression(Symbol))
      stub = NullStub.new(expected.value).as(Stub)
      initialize(stub)
    end

    # Returns a new matcher with an argument constraint.
    def with(*args, **kwargs) : self
      stub = @stub.with(*args, **kwargs)
      self.class.new(stub)
    end

    # Short text about the matcher's purpose.
    def description : String
      "received #{@stub}"
    end

    # Actually performs the test against the expression (value or block).
    def match(actual : Expression(Stubbable) | Expression(StubbedType)) : MatchData
      stubbed = actual.value
      if stubbed._spectator_calls.any? { |call| @stub === call }
        SuccessfulMatchData.new("#{actual.label} received #{@stub}")
      else
        FailedMatchData.new("#{actual.label} received #{@stub}", "#{actual.label} did not receive #{@stub}", values(actual).to_a)
      end
    end

    # Actually performs the test against the expression (value or block).
    def match(actual : Expression(T)) : MatchData forall T
      {% raise "Value being checked with `have_received` must be stubbable (mock or double)." %}
    end

    # Performs the test against the expression (value or block), but inverted.
    def negated_match(actual : Expression(Stubbable) | Expression(StubbedType)) : MatchData
      stubbed = actual.value
      if stubbed._spectator_calls.any? { |call| @stub === call }
        FailedMatchData.new("#{actual.label} did not receive #{@stub}", "#{actual.label} received #{@stub}", negated_values(actual).to_a)
      else
        SuccessfulMatchData.new("#{actual.label} did not receive #{@stub}")
      end
    end

    # Performs the test against the expression (value or block), but inverted.
    def negated_match(actual : Expression(T)) : MatchData forall T
      {% raise "Value being checked with `have_received` must be stubbable (mock or double)." %}
    end

    private def match_data_description(actual : Expression(T)) : String forall T
      match_data_description(actual.label)
    end

    private def match_data_description(actual_label : String | Symbol) : String
      "#{actual_label} #{description}"
    end

    private def match_data_description(actual_label : Nil) : String
      description
    end

    # Additional information about the match failure.
    private def values(actual : Expression(T)) forall T
      {
        expected: @stub.to_s,
        actual:   actual.value._spectator_calls.join("\n"),
      }
    end

    # Additional information about the match failure when negated.
    private def negated_values(actual : Expression(T)) forall T
      {
        expected: "Not #{@stub}",
        actual:   actual.value._spectator_calls.join("\n"),
      }
    end
  end
end
