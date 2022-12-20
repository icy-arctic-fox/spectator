require "json"
require "./expression"
require "./location"

module Spectator
  # Result of evaluating a matcher on a target.
  # Contains information about the match,
  # such as whether it was successful and a description of the operation.
  struct Expectation
    # Location of the expectation in source code.
    # This can be nil if the location can't be captured,
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

      # Asserts that a method is called some point before the example completes.
      @[AlwaysInline]
      def to(stub : Stub, message = nil) : Nil
        {% raise "The syntax `expect(...).to receive(...)` requires the expression passed to `expect` be stubbable (a mock or double)" unless T < ::Spectator::Stubbable || T < ::Spectator::StubbedType %}

        to_eventually(stub, message)
      end

      # Asserts that some criteria defined by the matcher is satisfied.
      # Allows a custom message to be used.
      def to(matcher, message = nil) : Nil
        match_data = matcher.match(@expression)
        report(match_data, message)
      end

      # Asserts that some criteria defined by the matcher is satisfied.
      # Allows a custom message to be used.
      # Returns the expected value cast as the expected type, if the matcher is satisfied.
      def to(matcher : Matchers::TypeMatcher(U), message = nil) forall U
        match_data = matcher.match(@expression)
        value = @expression.value
        if report(match_data, message)
          return value if value.is_a?(U)

          raise "Spectator bug: expected value should have cast to #{U}"
        else
          raise TypeCastError.new("#{@expression.label} is expected to be a #{U}, but was actually #{value.class}")
        end
      end

      # Asserts that a method is not called before the example completes.
      @[AlwaysInline]
      def to_not(stub : Stub, message = nil) : Nil
        {% raise "The syntax `expect(...).to_not receive(...)` requires the expression passed to `expect` be stubbable (a mock or double)" unless T < ::Spectator::Stubbable || T < ::Spectator::StubbedType %}

        to_never(stub, message)
      end

      # :ditto:
      @[AlwaysInline]
      def not_to(stub : Stub, message = nil) : Nil
        to_not(stub, message)
      end

      # Asserts that some criteria defined by the matcher is not satisfied.
      # This is effectively the opposite of `#to`.
      # Allows a custom message to be used.
      def to_not(matcher, message = nil) : Nil
        match_data = matcher.negated_match(@expression)
        report(match_data, message)
      end

      # Asserts that some criteria defined by the matcher is not satisfied.
      # Allows a custom message to be used.
      # Returns the expected value cast without the unexpected type, if the matcher is satisfied.
      def to_not(matcher : Matchers::TypeMatcher(U), message = nil) forall U
        match_data = matcher.negated_match(@expression)
        value = @expression.value
        if report(match_data, message)
          return value unless value.is_a?(U)

          raise "Spectator bug: expected value should not be #{U}"
        else
          raise TypeCastError.new("#{@expression.label} is not expected to be a #{U}, but was actually #{value.class}")
        end
      end

      # Asserts that some criteria defined by the matcher is not satisfied.
      # Allows a custom message to be used.
      # Returns the expected value cast as a non-nillable type, if the matcher is satisfied.
      def to_not(matcher : Matchers::NilMatcher, message = nil)
        match_data = matcher.negated_match(@expression)
        if report(match_data, message)
          value = @expression.value
          return value unless value.nil?

          raise "Spectator bug: expected value should not be nil"
        else
          raise NilAssertionError.new("#{@expression.label} is not expected to be nil.")
        end
      end

      # :ditto:
      @[AlwaysInline]
      def not_to(matcher, message = nil) : Nil
        to_not(matcher, message)
      end

      # Asserts that a method is called some point before the example completes.
      def to_eventually(stub : Stub, message = nil) : Nil
        {% raise "The syntax `expect(...).to_eventually receive(...)` requires the expression passed to `expect` be stubbable (a mock or double)" unless T < ::Spectator::Stubbable || T < ::Spectator::StubbedType %}

        stubbable = @expression.value
        unless stubbable._spectator_stub_for_method?(stub.method)
          # Add stub without an argument constraint.
          # Avoids confusing logic like this:
          # ```
          # expect(dbl).to receive(:foo).with(:bar)
          # dbl.foo(:baz)
          # ```
          # Notice that `#foo` is called, but with different arguments.
          # Normally this would raise an error, but that should be prevented.
          unconstrained_stub = stub.with(Arguments.any)
          stubbable._spectator_define_stub(unconstrained_stub)
        end

        # Apply the stub that is expected to be called.
        stubbable._spectator_define_stub(stub)

        # Check if the stub was invoked after the test completes.
        matcher = Matchers::ReceiveMatcher.new(stub)
        Harness.current.defer { to(matcher, message) }

        # Prevent leaking stubs between tests.
        Harness.current.cleanup { stubbable._spectator_remove_stub(stub) }
      end

      # Asserts that some criteria defined by the matcher is eventually satisfied.
      # The expectation is checked after the example finishes and all hooks have run.
      # Allows a custom message to be used.
      def to_eventually(matcher, message = nil) : Nil
        Harness.current.defer { to(matcher, message) }
      end

      # Asserts that a method is not called before the example completes.
      def to_never(stub : Stub, message = nil) : Nil
        {% raise "The syntax `expect(...).to_never receive(...)` requires the expression passed to `expect` be stubbable (a mock or double)" unless T < ::Spectator::Stubbable || T < ::Spectator::StubbedType %}

        stubbable = @expression.value
        unless stubbable._spectator_stub_for_method?(stub.method)
          # Add stub without an argument constraint.
          # Avoids confusing logic like this:
          # ```
          # expect(dbl).to receive(:foo).with(:bar)
          # dbl.foo(:baz)
          # ```
          # Notice that `#foo` is called, but with different arguments.
          # Normally this would raise an error, but that should be prevented.
          unconstrained_stub = stub.with(Arguments.any)
          stubbable._spectator_define_stub(unconstrained_stub)
        end

        # Apply the stub that could be called in case it is.
        stubbable._spectator_define_stub(stub)

        # Check if the stub was invoked after the test completes.
        matcher = Matchers::ReceiveMatcher.new(stub)
        Harness.current.defer { to_not(matcher, message) }

        # Prevent leaking stubs between tests.
        Harness.current.cleanup { stubbable._spectator_remove_stub(stub) }
      end

      # :ditto:
      @[AlwaysInline]
      def never_to(stub : Stub, message = nil) : Nil
        to_never(stub, message)
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

      # Reports an expectation to the current harness.
      private def report(match_data : Matchers::MatchData, message : String? | Proc(String) = nil)
        expectation = Expectation.new(match_data, @location, message)
        Harness.current.report(expectation)
      end
    end
  end
end
