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
  end
end
