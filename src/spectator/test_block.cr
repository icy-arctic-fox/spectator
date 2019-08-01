require "./test_expression"

module Spectator
  # Captures an block from a test and its label.
  struct TestBlock(ReturnType) < TestExpression
    # Calls the block and retrieves the value.
    def value : ReturnType
      @proc.call
    end

    # Creates the block expression with a custom label.
    # Typically the label is the code in the block/proc.
    def initialize(label : String, @proc : -> ReturnType)
      super(label)
    end

    # Creates the block expression with a generic label.
    # This is used for the "should" syntax and when the label doesn't matter.
    def initialize(@proc : -> ReturnType)
      super("<Proc>")
    end

    # Reports complete information about the expression.
    def inspect(io)
      io << label
      io << " -> "
      io << value
    end
  end
end
