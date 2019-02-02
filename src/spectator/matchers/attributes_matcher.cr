require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests that multiple attributes match specified conditions.
  # The attributes are tested with the `===` operator.
  # The `ExpectedType` type param should be a `NamedTuple`.
  struct AttributesMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      actual = partial.actual

      # Test each attribute and immediately return false if a comparison fails.
      {% for attribute in ExpectedType.keys %}
      return false unless expected[{{attribute.symbolize}}] === actual.{{attribute}}
      {% end %}

      # All checks passed if this point is reached.
      true
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to have #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not have #{label}"
    end
  end
end
