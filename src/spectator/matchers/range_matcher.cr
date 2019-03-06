require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is in a given range or set of values.
  # The `includes?` method is used for this check.
  # Typically this matcher uses a `Range`,
  # but any type that implements the `includes?` method is supported.
  struct RangeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      expected.includes?(actual)
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      matched = match?(actual)
      expected_value = @expected
      if expected_value.is_a?(Range)
        RangeMatchData.new(matched, ExpectedActual.new(expected_value, label, actual, partial.label))
      else
        SetMatchData.new(matched, ExpectedActual.new(partial, self))
      end
    end

    # Creates a new range matcher with bounds based off of *center*.
    #
    # This method expects that the original matcher was created with a "difference" value.
    # That is:
    # ```
    # RangeMatcher.new(diff).of(center)
    # ```
    # This implies that the `#match` method would not work on the original matcher.
    #
    # The new range will be centered at *center*
    # and have upper and lower bounds equal to *center* plus and minus diff.
    # The range will be inclusive.
    def of(center)
      diff = @expected
      lower = center - diff
      upper = center + diff
      range = Range.new(lower, upper)
      RangeMatcher.new(range, "#{center} +/- #{label}")
    end

    # Returns a new matcher, with the same bounds, but uses an inclusive range.
    def inclusive
      range = Range.new(@expected.begin, @expected.end, exclusive: false)
      RangeMatcher.new(range, label)
    end

    # Returns a new matcher, with the same bounds, but uses an exclusive range.
    def exclusive
      range = Range.new(@expected.begin, @expected.end, exclusive: true)
      RangeMatcher.new(range, label)
    end

    # Match data specific to this matcher.
    # This is used when the expected type is a `Range`.
    private struct RangeMatchData(B, E, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(Range(B, E), ActualType))
        super(matched)
      end

      # Information about the match.
      def values
        {
          lower:  PrefixedValue.new(">=", range.begin),
          upper:  PrefixedValue.new(exclusive? ? "<" : "<=", range.end),
          actual: @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} is in #{@values.expected_label} (#{exclusivity})"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} is not in #{@values.expected_label} (#{exclusivity})"
      end

      # Gets the expected range.
      private def range
        @values.expected
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

    # Match data specific to this matcher.
    # This is used when the expected type is not a `Range`.
    private struct SetMatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def values
        {
          set:    @values.expected,
          actual: @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} is in #{@values.expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} is not in #{@values.expected_label}"
      end
    end
  end
end
