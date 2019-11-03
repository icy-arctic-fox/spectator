require "../mocks/double"
require "./standard_matcher"

module Spectator::Matchers
  struct ReceiveMatcher < StandardMatcher
    def initialize(@expected : TestExpression(Symbol), @count : Int32? = nil)
    end

    def description : String
      "received message #{@expected.label}"
    end

    def match?(actual : TestExpression(T)) : Bool forall T
      double = actual.value.as(Mocks::Double)
      calls = double.spectator_stub_calls(@expected.value)
      if (count = @count)
        count == calls.size
      else
        !calls.empty?
      end
    end

    def failure_message(actual : TestExpression(T)) : String forall T
      "#{actual.label} did not receive #{@expected.label}"
    end

    def values(actual : TestExpression(T)) forall T
      double = actual.value.as(Mocks::Double)
      calls = double.spectator_stub_calls(@expected.value)
      {
        expected: "#{@count ? "#{@count} time(s)" : "At least once"} with any arguments",
        received: "#{calls.size} time(s) with any arguments",
      }
    end
  end
end
