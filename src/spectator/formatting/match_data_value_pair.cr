module Spectator::Formatting
  # A single key-value pair from the `Spectator::Matchers::MatchData#value` method.
  private struct MatchDataValuePair(T)
    # Creates the pair formatter.
    def initialize(@key : Symbol, @value : T)
    end

    # Appends the pair to the output.
    def to_s(io)
      io << @key
      io << ": "
      @value.inspect(io)
    end
  end
end
