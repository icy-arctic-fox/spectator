require "./standard_matcher"

module Spectator::Matchers
  # Category of matcher that uses a value.
  # Matchers of this type expect that a SUT applies to the value in some way.
  abstract struct ValueMatcher(ExpectedType) < StandardMatcher
    # Expected value.
    # Sub-types may use this value to test the expectation and generate message strings.
    private getter expected

    # Creates the value matcher.
    # The expected value is stored for later use.
    def initialize(@expected : TestValue(ExpectedType))
    end

    private def values(actual)
      super.merge(expected: expected.value.inspect)
    end

    private def negated_values(actual)
      super.merge(expected: "Not #{expected.value.inspect}")
    end
  end
end
