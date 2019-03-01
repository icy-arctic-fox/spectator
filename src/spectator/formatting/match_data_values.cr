module Spectator::Formatting
  # Produces a `MatchDataValuePair` for each key-value pair
  # from `Spectator::Matchers::MatchData#values`.
  private struct MatchDataValues(T)
    include Enumerable(MatchDataValuePair)

    # Creates the values mapper.
    def initialize(@values : T)
    end

    # Yields pairs that can be printed to output.
    def each
      @values.each do |key, value|
        yield MatchDataValuePair.new(key, value)
      end
    end
  end
end
