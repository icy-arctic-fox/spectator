require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is in a given range.
  # The `Range#includes?` method is used for this check.
  struct RangeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value.includes?(actual.value)
    end

    def description
      "is in #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is not in #{expected.label} (#{exclusivity})"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is in #{expected.label} (#{exclusivity})"
    end

    private def values(actual)
      {
        lower:  ">= #{range.begin.inspect}",
        upper:  "#{exclusive? ? "<" : "<="} #{range.end.inspect}",
        actual: actual.value.inspect,
      }
    end

    private def negated_values(actual)
      {
        lower:  "< #{range.begin.inspect}",
        upper:  "#{exclusive? ? ">=" : ">"} #{range.end.inspect}",
        actual: actual.value.inspect,
      }
    end

    # Returns a new matcher, with the same bounds, but uses an inclusive range.
    def inclusive
      new_range = Range.new(range.begin, range.end, exclusive: false)
      expected = TestValue.new(new_range, label)
      RangeMatcher.new(expected)
    end

    # Returns a new matcher, with the same bounds, but uses an exclusive range.
    def exclusive
      new_range = Range.new(range.begin, range.end, exclusive: true)
      expected = TestValue.new(new_range, label)
      RangeMatcher.new(expected)
    end

    # Gets the expected range.
    private def range
      expected.value
    end

    # Indicates whether the range is inclusive or exclusive.
    private def exclusive?
      range.exclusive?
    end

    # Produces a string "inclusive" or "exclusive" based on the range.
    private def exclusivity
      exclusive? ? "exclusive" : "inclusive"
    end
  end
end
