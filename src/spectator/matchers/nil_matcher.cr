require "./value_matcher"

module Spectator::Matchers
  # Common matcher that tests whether a value is nil.
  # The values are compared with the `#nil?` method.
  struct NilMatcher < ConditionMatcher
    # Creates the matcher.
    def initialize
      super("nil?")
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial) : Bool
      partial.actual.nil?
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial) : String
      "Expected #{partial.label} to be nil"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial) : String
      "Expected #{partial.label} to not be nil"
    end
  end
end
