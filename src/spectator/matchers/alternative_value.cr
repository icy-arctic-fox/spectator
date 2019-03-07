module Spectator::Matchers
  # Selects a value based on whether the value is negated.
  # This is used when a matcher is negated.
  private class AlternativeValue(T1, T2)
    # Negatable value.
    getter value

    # Creates the wrapper.
    def initialize(@value1 : T1, @value2 : T2)
      @negated = false
    end

    # Negates (toggles) the value.
    def negate
      @negated = !@negated
    end

    # Produces a stringified value.
    def to_s(io)
      io << @negated ? @value1 : @value2
    end

    # Produces a stringified value with additional information.
    def inspect(io)
      (@negated ? @value1 : @value2).inspect(io)
    end
  end
end
