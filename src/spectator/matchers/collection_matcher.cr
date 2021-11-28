require "../value"
require "./range_matcher"
require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that a value is in a collection of other values.
  struct CollectionMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is in #{expected.label}"
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      expected.value.includes?(actual.value)
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is not in #{expected.label}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
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
      value = Value.new(range, "#{center} ± #{expected.label}")
      RangeMatcher.new(value)
    end
  end
end
