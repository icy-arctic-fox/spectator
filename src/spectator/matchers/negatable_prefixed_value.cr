module Spectator::Matchers
  # Wraps a prefixed value that can be negated.
  # This is used when a matcher is negated.
  private class NegatablePrefixedValue(T)
    # Creates the wrapper.
    def initialize(@positive_prefix : String, @negative_prefix : String, @value : T)
      @negated = false
    end

    # Negates (toggles) the value.
    def negate
      @negated = !@negated
    end

    # Produces a stringified value.
    def to_s(io)
      io << @negated ? @negative_prefix : @positive_prefix
      io << @value
    end

    # Produces a stringified value with additional information.
    def inspect(io)
      io << @negated ? @negative_prefix : @positive_prefix
      @value.inspect(io)
    end
  end
end
