module Spectator::Formatting
  # Produces a `MatchDataValuePair` for each key-value pair
  # from `Spectator::Matchers::MatchData#values`.
  private struct MatchDataValues(T)
    include Enumerable(MatchDataValuePair)

    @max_key_length : Int32

    # Creates the values mapper.
    def initialize(@values : T)
      @max_key_length = T.types.keys.map(&.to_s.size).max
    end

    # Yields pairs that can be printed to output.
    def each
      @values.each do |key, value|
        key_length = key.to_s.size
        padding = @max_key_length - key_length
        yield MatchDataValuePair.new(key, value, padding)
      end
    end
  end
end
