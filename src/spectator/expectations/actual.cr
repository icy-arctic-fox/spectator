module Spectator::Expectations
  # Base class for capturing an actual value - the thing being checked/tested.
  abstract struct Actual
    # User-friendly string displayed for the actual expression being tested.
    # For instance, in the expectation:
    # ```
    # expect(foo).to eq(bar)
    # ```
    # This property will be "foo".
    # It will be the literal string "foo",
    # and not the actual value of the foo.
    getter label : String

    # Creates the common base of the actual value.
    def initialize(@label)
    end

    # String representation of the actual value.
    def to_s(io)
      io << label
    end
  end
end
