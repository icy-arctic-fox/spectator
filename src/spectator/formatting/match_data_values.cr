module Spectator::Formatting
  # Produces a `MatchDataValuePair` for each key-value pair
  # from `Spectator::Matchers::MatchData#values`.
  private struct MatchDataValues
    include Enumerable(MatchDataValuePair)

    @max_key_length : Int32

    # Creates the values mapper.
    def initialize(@values : Array(Spectator::Matchers::MatchDataLabeledValue))
      @max_key_length = @values.map(&.label.to_s.size).max
    end

    # Yields pairs that can be printed to output.
    def each
      @values.each do |labeled_value|
        key = labeled_value.label
        key_length = key.to_s.size
        padding = @max_key_length - key_length
        yield MatchDataValuePair.new(key, labeled_value.value, padding)
      end
    end
  end
end
