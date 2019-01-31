module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Textual representation of what the matcher expects.
    # This shouldn't be used in the conditional logic,
    # but for verbose output to help the end-user.
    private getter label : String

    # Creates the base of the matcher.
    private def initialize(@label)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    abstract def match?(partial) : Bool

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    abstract def message(partial) : String

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    abstract def negated_message(partial) : String
  end
end
