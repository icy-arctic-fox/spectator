require "./matcher_dsl"

module Spectator::DSL
  # Methods that are available inside test code (an `it` block).
  module ExampleDSL
    include MatcherDSL

    # Starts an expectation.
    # This should be followed up with `to` or `to_not`.
    # The value passed in will be checked
    # to see if it satisfies the conditions specified.
    #
    # This method should be used like so:
    # ```
    # expect(actual).to eq(expected)
    # ```
    # Where the actual value is returned by the system-under-test,
    # and the expected value is what the actual value should be to satisfy the condition.
    macro expect(actual)
      ::Spectator::Expectations::ValueExpectationPartial.new({{actual.stringify}}, {{actual}})
    end

    # Short-hand for expecting something of the subject.
    # These two are functionally equivalent:
    # ```
    # expect(subject).to eq("foo")
    # is_expected.to eq("foo")
    # ```
    macro is_expected
      expect(subject)
    end

    # Immediately fail the current test.
    # A reason can be passed,
    # which is reported in the output.
    def fail(reason : String)
      raise ExampleFailed.new(reason)
    end

    # ditto
    @[AlwaysInline]
    def fail
      fail("Example failed")
    end
  end
end
