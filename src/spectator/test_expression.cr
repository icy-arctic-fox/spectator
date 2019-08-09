module Spectator
  # Base type for capturing an expression from a test.
  abstract struct TestExpression(T)
    # User-friendly string displayed for the actual expression being tested.
    # For instance, in the expectation:
    # ```
    # expect(foo).to eq(bar)
    # ```
    # This property will be "foo".
    # It will be the literal string "foo",
    # and not the actual value of the foo.
    getter label : String

    # Creates the common base of the expression.
    def initialize(@label)
    end

    abstract def value : T

    # String representation of the expression.
    def to_s(io)
      io << label
    end
  end
end
