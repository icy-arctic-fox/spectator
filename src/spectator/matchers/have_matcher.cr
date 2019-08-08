require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches one or more values.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until === is true.
  struct HaveMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      actual_value = actual.value
      if actual_value.is_a?(String)
        match_string(actual_value)
      else
        match_enumerable(actual_value)
      end
    end

    # Checks if a `String` matches the expected values.
    # The `includes?` method is used for this check.
    private def match_string?(actual_value)
      expected.value.all? do |item|
        actual_value.includes?(item)
      end
    end

    # Checks if an `Enumerable` matches the expected values.
    # The `===` operator is used on every item.
    private def match_enumerable?(actual_value)
      array = actual_value.to_a
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
