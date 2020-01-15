require "./match_data"

module Spectator::Matchers
  # Information about a failed match.
  struct FailedMatchData < MatchData
    # Indicates that the match failed.
    def matched? : Bool
      false
    end

    # Description from the matcher as to why it failed.
    getter failure_message : String

    # Additional information from the match that can be used to debug the problem.
    getter values : Array(Tuple(Symbol, String))

    # Creates the match data.
    def initialize(description, @failure_message, @values)
      super(description)
    end

    # Creates the match data.
    def initialize(description, @failure_message, **values)
      super(description)
      @values = values.to_a
    end
  end
end
