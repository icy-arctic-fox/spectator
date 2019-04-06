require "./match_data_value"

module Spectator::Matchers
  # Prefixes (for output formatting) an actual or expected value.
  private class PrefixedMatchDataValue(T) < MatchDataValue
    # Value being prefixed.
    getter value : T

    # Creates the prefixed value.
    def initialize(@prefix : String, @value : T)
    end

    # Outputs the formatted value with a prefix.
    def to_s(io)
      io << @prefix
      io << ' '
      @value.inspect(io)
    end

    # Outputs details of the formatted value with a prefix.
    def inspect(io)
      io << @prefix
      io << ' '
      @prefix.inspect(io)
    end
  end
end
