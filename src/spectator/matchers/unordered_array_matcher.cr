require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another, but in any order.
  struct UnorderedArrayMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "contains #{expected.label} in any order"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a
      missing, extra = array_diff(expected_elements, actual_elements)

      if missing.empty? && extra.empty?
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual_label} does not contain #{expected.label} (unordered)",
          expected: expected_elements.inspect,
          actual: actual_elements.inspect,
          missing: missing.inspect,
          extra: extra.inspect,
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a
      missing, extra = array_diff(expected_elements, actual_elements)

      if missing.empty? && extra.empty?
        FailedMatchData.new("#{actual_label} contains #{expected.label} (unordered)",
          expected: "Not #{expected_elements.inspect}",
          actual: actual_elements.inspect,
        )
      else
        SuccessfulMatchData.new
      end
    end

    # Finds the difference of two unordered arrays.
    # Returns a tuple of arrays - missing from *actual* and extra in *actual*.
    private def array_diff(expected, actual)
      extra = actual.dup
      missing = [] of ExpectedType

      # OPTIMIZE: Not very efficient at finding the difference.
      expected.each do |item|
        index = extra.index(item)
        if index
          extra.delete_at(index)
        else
          missing << item
        end
      end

      {missing, extra}
    end
  end
end
