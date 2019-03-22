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
    abstract def values : Array(MatchDataLabeledValue)

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    abstract def message : String

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    abstract def negated_message : String
  end
end
