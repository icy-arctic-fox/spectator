require "./matcher"

module Spectator::Matchers
  # Matcher that tests a value is of a specified type.
  # The values are compared with the `Object#is_a?` method.
  struct TypeMatcher(Expected) < Matcher
    # Creates the type matcher.
    # The `Expected` type param will be used to populate the underlying label.
    def initialize
      super(Expected.to_s)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      partial.actual.is_a?(Expected)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to be a #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not be a #{label}"
    end
  end
end
