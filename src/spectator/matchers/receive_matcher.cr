require "../mocks/stub"
require "../mocks/stubbable"
require "../mocks/stubbed_type"
require "./matcher"

module Spectator::Matchers
  # Matcher that inspects stubbable objects for method calls.
  struct ReceiveMatcher < Matcher
    alias Count = Range(Int32?, Int32?)

    # Creates the matcher for expecting a method call matching a stub.
    def initialize(@stub : Stub, @count : Count = Count.new(1, nil))
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
      self.class.new(stub, @count)
    end

    # Short text about the matcher's purpose.
    def description : String
      "received #{@stub} #{humanize_count}"
    end

    # Actually performs the test against the expression (value or block).
    def match(actual : Expression(Stubbable) | Expression(StubbedType)) : MatchData
      stubbed = actual.value
      calls = relevant_calls(stubbed)
      if @count.includes?(calls.size)
        SuccessfulMatchData.new("#{actual.label} received #{@stub} #{humanize_count}")
      else
        FailedMatchData.new("#{actual.label} received #{@stub} #{humanize_count}",
          "#{actual.label} did not receive #{@stub}", values(actual).to_a)
      end
    end

    # Actually performs the test against the expression (value or block).
    def match(actual : Expression(T)) : MatchData forall T
      {% raise "Value being checked with `have_received` must be stubbable (mock or double)." %}
    end

    # Performs the test against the expression (value or block), but inverted.
    def negated_match(actual : Expression(Stubbable) | Expression(StubbedType)) : MatchData
      stubbed = actual.value
      calls = relevant_calls(stubbed)
      if @count.includes?(calls.size)
        FailedMatchData.new("#{actual.label} did not receive #{@stub}", "#{actual.label} received #{@stub}", negated_values(actual).to_a)
      else
        SuccessfulMatchData.new("#{actual.label} did not receive #{@stub} #{humanize_count}")
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
        actual:   method_call_list(actual.value),
      }
    end

    # Additional information about the match failure when negated.
    private def negated_values(actual : Expression(T)) forall T
      {
        expected: "Not #{@stub}",
        actual:   method_call_list(actual.value),
      }
    end

    # Filtered list of method calls relevant to the matcher.
    private def relevant_calls(stubbable)
      stubbable._spectator_calls.select { |call| @stub === call }
    end

    private def humanize_count
      case {@count.begin, @count.end}
      when {Int32, nil} then "at least #{@count.begin} times"
      when {nil, Int32} then "at most #{@count.end} times"
      else                   "any number of times"
      end
    end

    # Formatted list of method calls.
    private def method_call_list(stubbable)
      calls = stubbable._spectator_calls
      if calls.empty?
        "None"
      else
        calls.join("\n")
      end
    end
  end
end
