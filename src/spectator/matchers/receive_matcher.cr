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

    # Returns a new matcher that checks that the stub was invoked once.
    def once : self
      self.class.new(@stub, Count.new(1, 1))
    end

    # Returns a new matcher that checks that the stub was invoked twice.
    def twice : self
      self.class.new(@stub, Count.new(2, 2))
    end

    # Returns a new matcher that checks that the stub was invoked an exact number of times.
    def exactly(count : Int) : self
      self.class.new(@stub, Count.new(count, count))
    end

    # Returns a new matcher that checks that the stub was invoked at least a set amount of times.
    def at_least(count : Int) : self
      self.class.new(@stub, Count.new(count, nil))
    end

    # Returns a new matcher that checks that the stub was invoked at most a set amount of times.
    def at_most(count : Int) : self
      self.class.new(@stub, Count.new(nil, count))
    end

    # Returns a new matcher that checks that the stub was invoked at least once.
    def at_least_once : self
      self.class.new(@stub, Count.new(1, nil))
    end

    # Returns a new matcher that checks that the stub was invoked at least twice.
    def at_least_twice : self
      self.class.new(@stub, Count.new(2, nil))
    end

    # Returns a new matcher that checks that the stub was invoked at most once.
    def at_most_once : self
      self.class.new(@stub, Count.new(nil, 1))
    end

    # Returns a new matcher that checks that the stub was invoked at most twice.
    def at_most_twice : self
      self.class.new(@stub, Count.new(nil, 2))
    end

    # Returns self - used for fluent interface.
    #
    # ```
    # expect(dbl).to have_received(:foo).exactly(5).times
    # ```
    def times : self
      self
    end

    # Short text about the matcher's purpose.
    def description : String
      "received #{@stub.message} #{humanize_count}"
    end

    # Actually performs the test against the expression (value or block).
    def match(actual : Expression(Stubbable) | Expression(StubbedType)) : MatchData
      stubbed = actual.value
      calls = relevant_calls(stubbed)
      if @count.includes?(calls.size)
        SuccessfulMatchData.new("#{actual.label} received #{@stub.message} #{humanize_count}")
      else
        FailedMatchData.new("#{actual.label} received #{@stub.message} #{humanize_count}",
          "#{actual.label} did not receive #{@stub.message}", values(actual).to_a)
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
        FailedMatchData.new("#{actual.label} did not receive #{@stub.message}", "#{actual.label} received #{@stub.message}", negated_values(actual).to_a)
      else
        SuccessfulMatchData.new("#{actual.label} did not receive #{@stub.message} #{humanize_count}")
      end
    end

    # Performs the test against the expression (value or block), but inverted.
    def negated_match(actual : Expression(T)) : MatchData forall T
      {% raise "Value being checked with `have_received` must be stubbable (mock or double)." %}
    end

    # Additional information about the match failure.
    private def values(actual : Expression(T)) forall T
      {
        expected: @stub.message,
        actual:   method_call_list(actual.value),
      }
    end

    # Additional information about the match failure when negated.
    private def negated_values(actual : Expression(T)) forall T
      {
        expected: "Not #{@stub.message}",
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
