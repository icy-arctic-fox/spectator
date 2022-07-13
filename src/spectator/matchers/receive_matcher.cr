require "../mocks/stub"
require "../mocks/stubbable"
require "../mocks/stubbed_type"
require "./matcher"

module Spectator::Matchers
  # Matcher that inspects stubbable objects for method calls.
  struct ReceiveMatcher < Matcher
    # Creates the matcher for expecting a method call matching a stub.
    def initialize(@stub : Stub)
    end

    # Creates the matcher for expecting a method call with any arguments.
    # *expected* is an expression evaluating to the method name as a symbol.
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
