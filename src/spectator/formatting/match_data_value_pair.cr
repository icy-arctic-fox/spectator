module Spectator::Formatting
  # A single key-value pair from the `Spectator::Matchers::MatchData#value` method.
  private struct MatchDataValuePair(T)
    # Creates the pair formatter.
    def initialize(@key : Symbol, @value : T, @padding : Int32)
    end

    # Appends the pair to the output.
    def to_s(io)
      @padding.times { io << ' ' }
      io << @key
      io << ": "
      @value.inspect(io)
    end
  end
end
