require "./matcher"

module Spectator::Matchers
  # Category of matcher that uses a value.
  # Matchers of this type expect that a SUT applies to the value in some way.
  abstract struct ValueMatcher(ExpectedType) < Matcher
    # Expected value.
    # Sub-types may use this value to test the expectation and generate message strings.
    private getter expected : TestValue(ExpectedType)

    # Creates the value matcher.
    # The expected value is stored for later use.
    def initialize(@expected)
    end

    private def values(actual) : Array(LabeledValue)
      super(actual) << LabeledValue.new(expected.value.to_s, "expected")
    end

    private def negated_values(actual) : Array(LabeledValue)
      super(actual) << LabeledValue.new("Not #{expected.value}", "expected")
    end
  end
end
