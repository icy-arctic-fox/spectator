module Spectator::Formatting
  # A single labeled value from the `Spectator::Matchers::MatchData#value` method.
  private struct MatchDataValuePair
    # Creates the pair formatter.
    def initialize(@key : Symbol, @value : String, @padding : Int32)
    end

    # Appends the pair to the output.
    def to_s(io)
      @padding.times { io << ' ' }
      io << @key
      io << ": "
      io << @value
    end
  end
end
