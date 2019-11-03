require "../mocks/double"
require "./standard_matcher"

module Spectator::Matchers
  struct ReceiveMatcher < StandardMatcher
    alias Range = ::Range(Int32, Int32) | ::Range(Nil, Int32) | ::Range(Int32, Nil)

    def initialize(@expected : TestExpression(Symbol), @range : Range? = nil)
    end

    def description : String
      "received message #{@expected.label}"
    end

    def match?(actual : TestExpression(T)) : Bool forall T
      double = actual.value.as(Mocks::Double)
      calls = double.spectator_stub_calls(@expected.value)
      if (range = @range)
        range.includes?(calls.size)
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
      range = @range
      {
        expected: "#{range ? "#{humanize_range(range)} time(s)" : "At least once"} with any arguments",
        received: "#{calls.size} time(s) with any arguments",
      }
    end

    def once
      ReceiveMatcher.new(@expected, (1..1))
    end

    def twice
      ReceiveMatcher.new(@expected, (2..2))
    end

    def humanize_range(range : Range)
      if (min = range.begin)
        if (max = range.end)
          if min == max
            min
          else
            "#{min} to #{max}"
          end
        else
          "At least #{min}"
        end
      else
        if (max = range.end)
          "At most #{max}"
        else
          raise "Unexpected endless range"
        end
      end
    end
  end
end
