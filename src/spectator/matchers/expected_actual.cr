module Spectator::Matchers
  # Stores values and labels for expected and actual values.
  private struct ExpectedActual(ExpectedType, ActualType)
    # The expected value.
    getter expected : ExpectedType

    # The user label for the expected value.
    getter expected_label : String

    # The actual value.
    getter actual : ActualType

    # The user label for the actual value.
    getter actual_label : String

    # Creates the value and label store.
    def initialize(@expected : ExpectedType, @expected_label, @actual : ActualType, @actual_label)
    end

    # Creates the value and label store.
    # Attributes are pulled from an expectation partial and matcher.
    def initialize(
      partial : Spectator::Expectations::ValueExpectationPartial(ActualType) |
                Spectator::Expectations::BlockExpectationPartial(ActualType),
      matcher : ValueMatcher(ExpectedType)
    )
      initialize(matcher.expected, matcher.label, partial.actual, partial.label)
    end
  end
end
