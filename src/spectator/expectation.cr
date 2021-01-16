require "./expression"
require "./source"

module Spectator
  # Result of evaluating a matcher on a target.
  # Contains information about the match,
  # such as whether it was successful and a description of the operation.
  struct Expectation
    # Location of the expectation in source code.
    # This can be nil if the source isn't capturable,
    # for instance using the *should* syntax or dynamically created expectations.
    getter source : Source?

    # Creates the expectation.
    # The *match_data* comes from the result of calling `Matcher#match`.
    # The *source* is the location of the expectation in source code, if available.
    def initialize(@match_data : Matchers::MatchData, @source : Source? = nil)
    end

    # Stores part of an expectation.
    # This covers the actual value (or block) being inspected and its source.
    # This is the type returned by an `expect` block in the DSL.
    # It is not intended to be used directly, but instead by chaining methods.
    # Typically `#to` and `#not_to` are used.
    struct Target(T)
      # Creates the expectation target.
      # The *expression* is the actual value being tested and its label.
      # The *source* is the location of where this expectation was defined.
      def initialize(@expression : Expression(T), @source : Source)
        puts "TARGET: #{@expression} @ #{@source}"
      end

      # Asserts that some criteria defined by the matcher is satisfied.
      def to(matcher) : Nil
        match_data = matcher.match(@expression)
        report(match_data)
      end

      def to(stub : Mocks::MethodStub) : Nil
        Harness.current.mocks.expect(@expression.value, stub)
        value = Value.new(stub.name, stub.to_s)
        matcher = Matchers::ReceiveMatcher.new(value, stub.arguments?)
        to_eventually(matcher)
      end

      def to(stubs : Enumerable(Mocks::MethodStub)) : Nil
        stubs.each { |stub| to(stub) }
      end

      # Asserts that some criteria defined by the matcher is not satisfied.
      # This is effectively the opposite of `#to`.
      def to_not(matcher) : Nil
        match_data = matcher.negated_match(@expression)
        report(match_data)
      end

      def to_not(stub : Mocks::MethodStub) : Nil
        value = Value.new(stub.name, stub.to_s)
        matcher = Matchers::ReceiveMatcher.new(value, stub.arguments?)
        to_never(matcher)
      end

      def to_not(stubs : Enumerable(Mocks::MethodStub)) : Nil
        stubs.each { |stub| to_not(stub) }
      end

      # :ditto:
      @[AlwaysInline]
      def not_to(matcher) : Nil
        to_not(matcher)
      end

      # Asserts that some criteria defined by the matcher is eventually satisfied.
      # The expectation is checked after the example finishes and all hooks have run.
      def to_eventually(matcher) : Nil
        Harness.current.defer { to(matcher) }
      end

      def to_eventually(stub : Mocks::MethodStub) : Nil
        to(stub)
      end

      def to_eventually(stubs : Enumerable(Mocks::MethodStub)) : Nil
        to(stub)
      end

      # Asserts that some criteria defined by the matcher is never satisfied.
      # The expectation is checked after the example finishes and all hooks have run.
      def to_never(matcher) : Nil
        Harness.current.defer { to_not(matcher) }
      end

      def to_never(stub : Mocks::MethodStub) : Nil
        to_not(stub)
      end

      def to_never(stub : Enumerable(Mocks::MethodStub)) : Nil
        to_not(stub)
      end

      # :ditto:
      @[AlwaysInline]
      def never_to(matcher) : Nil
        to_never(matcher)
      end

      # Reports an expectation to the current harness.
      private def report(match_data : Matchers::MatchData)
        expectation = Expectation.new(match_data, @source)
        Harness.current.report(expectation)
      end
    end
  end
end
