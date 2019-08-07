require "../test_value"
require "./range_matcher"
require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that a value is in a collection of other values.
  struct CollectionMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    private def match?(actual)
      expected.value.includes?(actual.value)
    end

    def description
      "is in #{expected.label}"
    end

    private def failure_message(actual)
      "#{actual.label} is not in #{expected.label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is in #{expected.label}"
    end

    # Creates a new range matcher with bounds based off of *center*.
    #
    # This method expects that the original matcher was created with a "difference" value.
    # That is:
    # ```
    # CollectionMatcher.new(diff).of(center)
    # ```
    # This implies that the `#match` method would not work on the original matcher.
    #
    # The new range will be centered at *center*
    # and have upper and lower bounds equal to *center* plus and minus diff.
    # The range will be inclusive.
    def of(center)
      diff = @expected.value
      lower = center - diff
      upper = center + diff
      range = Range.new(lower, upper)
      test_value = TestValue.new(range, "#{center} +/- #{expected.label}")
      RangeMatcher.new(test_value)
    end
  end
end
