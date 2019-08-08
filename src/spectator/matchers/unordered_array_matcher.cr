require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another, but in any order.
  struct UnorderedArrayMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(Enumerable(ExpectedType)))
    end

    def description
      "contains #{expected.label} in any order"
    end

    def match(actual)
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

    def negated_match(actual)
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
