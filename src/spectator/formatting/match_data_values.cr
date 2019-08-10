module Spectator::Formatting
  # Produces a `MatchDataValuePair` for each key-value pair
  # from `Spectator::Matchers::MatchData#values`.
  private struct MatchDataValues
    include Enumerable(Tuple(Symbol, String))

    @max_key_length : Int32

    # Creates the values mapper.
    def initialize(@values : Array(Tuple(Symbol, String)))
      @max_key_length = @values.map(&.first.to_s.size).max
    end

    # Yields pairs that can be printed to output.
    def each
      @values.each do |labeled_value|
        key = labeled_value.first
        key_length = key.to_s.size
        padding = @max_key_length - key_length
        yield MatchDataValuePair.new(key, labeled_value.last, padding)
      end
    end
  end
end
