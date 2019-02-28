require "./match_data"

module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Textual representation of what the matcher expects.
    # This shouldn't be used in the conditional logic,
    # but for verbose output to help the end-user.
    getter label : String

    # Creates the base of the matcher.
    def initialize(@label)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    abstract def match(partial) : MatchData
  end
end
