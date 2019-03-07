module Spectator::Matchers
  # Wraps a prefixed value that can be negated.
  # This is used when a matcher is negated.
  private class NegatablePrefixedValue(T)
    # Negatable value.
    getter value
    
    # Creates the wrapper.
    def initialize(@positive_prefix : String, @negative_prefix : String, @value : T)
      @negated = false
    end

    # Negates (toggles) the value.
    def negate
      @negated = !@negated
    end

    # Returns the correct prefix based on the negated status.
    private def prefix
      @negated ? @negative_prefix : @positive_prefix
    end

    # Produces a stringified value.
    def to_s(io)
      io << prefix
      io << @value
    end

    # Produces a stringified value with additional information.
    def inspect(io)
      io << prefix
      @value.inspect(io)
    end
  end
end
