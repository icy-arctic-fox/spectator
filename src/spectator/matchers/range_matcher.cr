require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is in a given range or set of values.
  # The `includes?` method is used for this check.
  # Typically this matcher uses a `Range`,
  # but any type that implements the `includes?` method is supported.
  struct RangeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      @expected.includes?(partial.actual)
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to be in #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not be in #{label}"
    end

    # Creates a new range matcher with bounds based off of *center*.
    #
    # This method expects that the original matcher was created with a "difference" value.
    # That is:
    # ```
    # RangeMatcher.new(diff).of(center)
    # ```
    # This implies that the `match?` method would not work on the original matcher.
    #
    # The new range will be centered at *center*
    # and have upper and lower bounds equal to *center* plus and minux diff.
    # The range will be inclusive.
    def of(center)
      diff = @expected
      lower = center - diff
      upper = center + diff
      range = Range.new(lower, upper)
      RangeMatcher.new("#{center} +/- #{label}", range)
    end

    # Returns a new matcher, with the same bounds, but uses an inclusive range.
    def inclusive
      range = Range.new(@expected.begin, @expected.end, exclusive: false)
      RangeMatcher.new(label + " (inclusive)", range)
    end

    # Returns a new matcher, with the same bounds, but uses an exclusive range.
    def exclusive
      range = Range.new(@expected.begin, @expected.end, exclusive: true)
      RangeMatcher.new(label + " (exclusive)", range)
    end
  end
end
