module Spectator::Expectations
  # Base class for all expectation partials.
  # An "expectation partial" stores part of an expectation (obviously).
  # The part of the expectation this class covers is the actual value.
  # This can also cover a block's behavior.
  # Sub-types of this class are returned by the `DSL::ExampleDSL.expect` call.
  abstract struct ExpectationPartial
    # User-friendly string displayed for the actual expression being tested.
    # For instance, in the expectation:
    # ```
    # expect(foo).to eq(bar)
    # ```
    # This property will be "foo".
    # It will be the literal string "foo",
    # and not the actual value of the foo.
    getter label : String

    # Source file the expectation originated from.
    getter source_file : String

    # Line number in the source file the expectation originated from.
    getter source_line : Int32

    # Creates the base of the partial.
    private def initialize(@label, @source_file, @source_line)
    end

    # Asserts that some criteria defined by the matcher is satisfied.
    def to(matcher) : Nil
      report(eval(matcher))
    end

    # Asserts that some criteria defined by the matcher is not satisfied.
    # This is effectively the opposite of `#to`.
    def to_not(matcher) : Nil
      report(eval(matcher, true))
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher) : Nil
      to_not(matcher)
    end

    # Evaluates the expectation and returns it.
    private def eval(matcher, negated = false)
      match_data = matcher.match(self)
      Expectation.new(matched, negated, match_data)
    end

    # Reports an expectation to the current harness.
    private def report(expectation : Expectation)
      Internals::Harness.current.report_expectation(expectation)
    end
  end
end
