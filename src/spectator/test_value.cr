require "./test_expression"

module Spectator
  # Captures a value from a test and its label.
  struct TestValue(T) < TestExpression
    # Actual value.
    getter value : T

    # Creates the expression value with a custom label.
    def initialize(label : String, @value)
      super(label)
    end

    # Creates the expression with a stringified value.
    # This is used for the "should" syntax and when the label doesn't matter.
    def initialize(@value)
      super(@value.to_s)
    end

    # Reports complete information about the expression.
    def inspect(io)
      io << label
      io << '='
      io << @value
    end
  end

  alias LabeledValue = TestValue(String)
end
