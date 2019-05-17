require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that a value is in a collection of other values.
  struct CollectionMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      expected.includes?(actual)
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      matched = match?(actual)
      MatchData.new(matched, ExpectedActual.new(partial, self))
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

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          collection: NegatableMatchDataValue.new(@values.expected),
          actual:     @values.actual,
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
