require "../double"
require "./standard_matcher"

module Spectator::Matchers
  struct ReceiveMatcher < StandardMatcher
    def initialize(@expected : TestExpression(Symbol))
    end

    def description : String
      "received message #{@expected.label}"
    end

    def match?(actual : TestExpression(T)) : Bool forall T
      double = actual.value.as(Double)
      calls = double.spectator_stub_calls(@expected.value)
      !calls.empty?
    end

    def failure_message(actual : TestExpression(T)) : String forall T
      "#{actual.label} did not receive #{@expected.label}"
    end

    def values(actual : TestExpression(T)) forall T
      {
        expected: "1 time with any arguments",
        received: "0 times with any arguments"
      }
    end
  end
end
