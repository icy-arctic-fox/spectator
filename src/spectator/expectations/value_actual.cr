require "./actual"

module Spectator::Expectations
  # Captures an actual value and its label.
  struct ValueActual(T) < Actual
    # Actual value.
    getter value : T

    # Creates the actual with a custom label.
    def initialize(label : String, @value)
      super(label)
    end

    # Creates the actual with a stringified value.
    # This is used for the "should" syntax and when the label doesn't matter.
    def initialize(@value)
      super(@value.to_s)
    end

    # Reports complete information about the actual value.
    def inspect(io)
      io << label
      io << '='
      io << @value
    end
  end
end
