require "json"
require "./expression"
require "./location"

module Spectator
  # Result of evaluating a matcher on a target.
  # Contains information about the match,
  # such as whether it was successful and a description of the operation.
  struct Expectation
    # Location of the expectation in source code.
    # This can be nil if the location isn't capturable,
    # for instance using the *should* syntax or dynamically created expectations.
    getter! location : Location

    # Indicates whether the expectation was met.
    def satisfied?
      @match_data.matched?
    end

    # Indicates whether the expectation was not met.
    def failed?
      !satisfied?
    end

    # If nil, then the match was successful.
    def failure_message?
      return unless match_data = @match_data.as?(Matchers::FailedMatchData)

      case message = @message
      when String       then message
      when Proc(String) then @message = message.call # Cache result of call.
      else                   match_data.failure_message
      end
    end

    # Description of why the match failed.
    def failure_message
      failure_message?.not_nil!
    end

    # Additional information about the match, useful for debug.
    # If nil, then the match was successful.
    def values?
      @match_data.as?(Matchers::FailedMatchData).try(&.values)
    end

    # Additional information about the match, useful for debug.
    def values
      values?.not_nil!
    end

    def description
      @match_data.description
    end

    # Creates the expectation.
    # The *match_data* comes from the result of calling `Matcher#match`.
    # The *location* is the location of the expectation in source code, if available.
    # A custom *message* can be used in case of a failure.
    def initialize(@match_data : Matchers::MatchData, @location : Location? = nil,
                   @message : String? | Proc(String) = nil)
    end

    # Creates the JSON representation of the expectation.
    def to_json(json : JSON::Builder)
      json.object do
        if location = @location
          json.field("file_path", location.path)
          json.field("line_number", location.line)
        end
        json.field("satisfied", satisfied?)
        if (failed = @match_data.as?(Matchers::FailedMatchData))
          failed_to_json(failed, json)
        end
      end
    end

    # Adds failure information to a JSON structure.
    private def failed_to_json(failed : Matchers::FailedMatchData, json : JSON::Builder)
      json.field("failure", failed.failure_message)
      json.field("values") do
        json.object do
          failed.values.each do |pair|
            json.field(pair.first, pair.last)
          end
        end
      end
    end

    # Stores part of an expectation.
    # This covers the actual value (or block) being inspected and its location.
    # This is the type returned by an `expect` block in the DSL.
    # It is not intended to be used directly, but instead by chaining methods.
    # Typically `#to` and `#not_to` are used.
    struct Target(T)
      # Creates the expectation target.
      # The *expression* is the actual value being tested and its label.
      # The *location* is the location of where this expectation was defined.
      def initialize(@expression : Expression(T), @location : Location)
      end

      # Asserts that some criteria defined by the matcher is satisfied.
      # Allows a custom message to be used.
      def to(matcher, message = nil) : Nil
        match_data = matcher.match(@expression)
        report(match_data, message)
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
      # Allows a custom message to be used.
      def to_not(matcher, message = nil) : Nil
        match_data = matcher.negated_match(@expression)
        report(match_data, message)
      end

      # :ditto:
      @[AlwaysInline]
      def not_to(matcher, message = nil) : Nil
        to_not(matcher, message)
      end

      def to_not(stub : Mocks::MethodStub) : Nil
        value = Value.new(stub.name, stub.to_s)
        matcher = Matchers::ReceiveMatcher.new(value, stub.arguments?)
        to_never(matcher)
      end

      def to_not(stubs : Enumerable(Mocks::MethodStub)) : Nil
        stubs.each { |stub| to_not(stub) }
      end

      # Asserts that some criteria defined by the matcher is eventually satisfied.
      # The expectation is checked after the example finishes and all hooks have run.
      # Allows a custom message to be used.
      def to_eventually(matcher, message = nil) : Nil
        Harness.current.defer { to(matcher, message) }
      end

      def to_eventually(stub : Mocks::MethodStub) : Nil
        to(stub)
      end

      def to_eventually(stubs : Enumerable(Mocks::MethodStub)) : Nil
        to(stub)
      end

      # Asserts that some criteria defined by the matcher is never satisfied.
      # The expectation is checked after the example finishes and all hooks have run.
      # Allows a custom message to be used.
      def to_never(matcher, message = nil) : Nil
        Harness.current.defer { to_not(matcher, message) }
      end

      # :ditto:
      @[AlwaysInline]
      def never_to(matcher, message = nil) : Nil
        to_never(matcher, message)
      end

      def to_never(stub : Mocks::MethodStub) : Nil
        to_not(stub)
      end

      def to_never(stub : Enumerable(Mocks::MethodStub)) : Nil
        to_not(stub)
      end

      # Reports an expectation to the current harness.
      private def report(match_data : Matchers::MatchData, message : String? | Proc(String) = nil)
        expectation = Expectation.new(match_data, @location, message)
        Harness.current.report(expectation)
      end
    end
  end
end
