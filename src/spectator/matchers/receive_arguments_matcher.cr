require "../mocks"
require "./standard_matcher"

module Spectator::Matchers
  struct ReceiveArgumentsMatcher(T, NT) < StandardMatcher
    alias Range = ::Range(Int32, Int32) | ::Range(Nil, Int32) | ::Range(Int32, Nil)

    def initialize(@expected : TestExpression(Symbol), @args : Mocks::GenericArguments(T, NT), @range : Range? = nil)
    end

    def description : String
      range = @range
      "received message #{@expected.label} #{range ? "#{humanize_range(range)} time(s)" : "At least once"} with #{@args}"
    end

    def match?(actual : TestExpression(T)) : Bool forall T
      calls = Harness.current.mocks.calls_for(actual.value, @expected.value).select { |call| @args === call.args }
      if (range = @range)
        range.includes?(calls.size)
      else
        !calls.empty?
      end
    end

    def failure_message(actual : TestExpression(T)) : String forall T
      range = @range
      "#{actual.label} did not receive #{@expected.label} #{range ? "#{humanize_range(range)} time(s)" : "at least once"} with #{@args}"
    end

    def values(actual : TestExpression(T)) forall T
      calls = Harness.current.mocks.calls_for(actual.value, @expected.value).select { |call| @args === call.args }
      range = @range
      {
        expected: "#{range ? "#{humanize_range(range)} time(s)" : "At least once"} with #{@args}",
        received: "#{calls.size} time(s)",
      }
    end

    def once
      ReceiveArgumentsMatcher.new(@expected, @args, (1..1))
    end

    def twice
      ReceiveArgumentsMatcher.new(@expected, @args, (2..2))
    end

    def exactly(count)
      Count.new(@expected, (count..count))
    end

    def at_least(count)
      Count.new(@expected, (count..))
    end

    def at_most(count)
      Count.new(@expected, (..count))
    end

    def at_least_once
      at_least(1).times
    end

    def at_least_twice
      at_least(2).times
    end

    def at_most_once
      at_most(1).times
    end

    def at_most_twice
      at_most(2).times
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

    private struct Count
      def initialize(@expected : TestExpression(Symbol), @args : Mocks::Arguments, @range : Range)
      end

      def times
        ReceiveArgumentsMatcher.new(@expected, @args, @range)
      end
    end
  end
end
