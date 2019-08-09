require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches one or more values.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until === is true.
  struct HaveMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      if (value = actual.value).is_a?(String)
        match_string?(value)
      else
        match_enumerable?(value)
      end
    end

    # Checks if a `String` matches the expected values.
    # The `includes?` method is used for this check.
    private def match_string?(value)
      expected.value.all? do |item|
        value.includes?(item) if item.is_a?(Char | String)
      end
    end

    # Checks if an `Enumerable` matches the expected values.
    # The `===` operator is used on every item.
    private def match_enumerable?(value)
      array = value.to_a
      expected.value.all? do |item|
        array.any? do |element|
          item === element
        end
      end
    end

    def description
      "includes #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} does not include #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} includes #{expected.label}"
    end

    private def values(actual)
      {
        subset:   expected.value.inspect,
        superset: actual.value.inspect,
      }
    end
  end
end
