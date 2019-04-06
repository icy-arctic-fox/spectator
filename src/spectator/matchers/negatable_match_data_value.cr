require "./match_data_value"

module Spectator::Matchers
  # Wraps an expected value that can be negated.
  # This is used when a matcher is negated.
  private class NegatableMatchDataValue(T) < MatchDataValue
    # Negatable value.
    getter value

    # Creates the wrapper.
    def initialize(@value : T)
      @negated = false
    end

    # Negates (toggles) the value.
    def negate
      @negated = !@negated
    end

    # Produces a stringified value.
    # The string will be prefixed with "Not" when negated.
    def to_s(io)
      io << "Not " if @negated
      @value.inspect(io)
    end

    # Produces a stringified value with additional information.
    # The string will be prefixed with "Not" when negated.
    def inspect(io)
      io << "Not " if @negated
      @value.inspect(io)
    end
  end
end
