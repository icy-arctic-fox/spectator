module Spectator::Expectations
  # Ties together a partial, matcher, and their outcome.
  class Expectation
    # Populates the base portiion of the expectation with values.
    # The *matched* flag should be true if the matcher is satisfied with the partial.
    # The *negated* flag should be true if the expectation is inverted.
    # These options are mutually-exclusive in this context.
    # Don't flip the value of *matched* because *negated* is true.
    # The *match_data* is the value returned by `Spectator::Matcher#match`
    # when the expectation was evaluated.
    def initialize(@matched : Bool, @negated : Bool, @match_data : MatchData)
    end

    # Indicates whether the expectation was satisifed.
    # This is true if:
    # - The matcher was satisified and the expectation is not negated.
    # - The matcher wasn't satisfied and the expectation is negated.
    def satisfied?
      @matched ^ @negated
    end

    # Text that indicates the condition that must be met for the expectation to be satisifed.
    def expected_message
      @negated ? @match_data.negated_message : @match_data.message
    end

    # Text that indicates what the outcome was.
    def actual_message
      satisfied? ? @match_data.message : @match_data.negated_message
    end
  end
end
