require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a collection is empty.
  # The values are checked with the `#empty?` method.
  struct EmptyMatcher < ConditionMatcher
    # Creates the matcher.
    def initialize
      super("empty?")
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial) : Bool
      partial.actual.empty?
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial) : String
      "Expected #{partial.label} to be empty"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial) : String
      "Expected #{partial.label} to not be empty"
    end
  end
end
