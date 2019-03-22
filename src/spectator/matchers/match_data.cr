require "./match_data_labeled_value"
require "./match_data_value"
require "./generic_match_data_value"

module Spectator::Matchers
  # Information regarding a expectation parial and matcher.
  # `Matcher#match` will return a sub-type of this.
  abstract struct MatchData
    # Indicates whether the matcher was satisified with the expectation partial.
    getter? matched : Bool

    # Creates the base of the match data.
    # The *matched* argument indicates
    # whether the matcher was satisified with the expectation partial.
    def initialize(@matched)
    end

    # Information about the match.
    # Returned elments will differ by matcher,
    # but all will return a set of labeled values.
    def values : Array(MatchDataLabeledValue)
      named_tuple.map do |key, value|
        if value.is_a?(MatchDataValue)
          MatchDataLabeledValue.new(key, value)
        else
          wrapper = GenericMatchDataValue.new(value)
          MatchDataLabeledValue.new(key, wrapper)
        end
      end
    end

    # Raw information about the match.
    # Sub-types must implement this and return a `NamedTuple`
    # containing the match data values.
    # This will be transformed and returned by `#values`.
    private abstract def named_tuple

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    abstract def message : String

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    abstract def negated_message : String
  end
end
