module Spectator::Matchers
  # Prefixes (for output formatting) an actual or expected value.
  private struct PrefixedValue(T)
    # Value being prefixed.
    getter value : T

    # Creates the prefixed value.
    def initialize(@prefix : String, @value : T)
    end

    # Outputs the formatted value with a prefix.
    def to_s(io)
      io << @prefix
      io << ' '
      io << @value
    end
  end
end
