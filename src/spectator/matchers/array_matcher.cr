require "./failed_match_data"
require "./matcher"
require "./successful_match_data"
require "./unordered_array_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another but may be in any order.
  struct ArrayMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : Value(Array(ExpectedType)))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "contains exactly #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:to_a)

      actual_elements = actual_value.to_a
      expected_elements = expected.value
      missing, extra = compare_arrays(expected_elements, actual_elements)

      if missing.empty? && extra.empty?
        # Contents are identical.
        SuccessfulMatchData.new(match_data_description(actual))
      else
        # Content differs.
        FailedMatchData.new(match_data_description(actual), "#{actual.label} does not contain exactly #{expected.label}",
          expected: expected_elements.inspect,
          actual: actual_elements.inspect,
          missing: missing.empty? ? "None" : missing.inspect,
          extra: extra.empty? ? "None" : extra.inspect
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      actual_value = actual.value
      return unexpected(actual_value, actual.label) unless actual_value.responds_to?(:to_a)

      actual_elements = actual_value.to_a
      expected_elements = expected.value
      missing, extra = compare_arrays(expected_elements, actual_elements)

      if missing.empty? && extra.empty?
        # Contents are identical.
        FailedMatchData.new(match_data_description(actual), "#{actual.label} contains exactly #{expected.label}",
          expected: "Not #{expected_elements.inspect}",
          actual: actual_elements.inspect
        )
      else
        # Content differs.
        SuccessfulMatchData.new(match_data_description(actual))
      end
    end

    # Ensures the arrays elements are compared in order.
    # This is the default behavior for the matcher.
    def in_order
      self
    end

    # Specifies that the arrays elements can be compared in any order.
    # The elements can be in a different order, but both arrays must have the same elements.
    def in_any_order
      UnorderedArrayMatcher.new(expected)
    end

    # Compares two arrays to determine whether they contain the same elements, but in any order.
    # A tuple of two arrays is returned.
    # The first array is the missing elements (present in expected, missing in actual).
    # The second array array is the extra elements (not present in expected, present in actual).
    private def compare_arrays(expected_elements, actual_elements)
      # Produce hashes where the array elements are the keys, and the values are the number of occurrences.
      expected_hash = expected_elements.group_by(&.itself).map { |k, v| {k, v.size} }.to_h
      actual_hash = actual_elements.group_by(&.itself).map { |k, v| {k, v.size} }.to_h

      {
        hash_count_difference(expected_hash, actual_hash),
        hash_count_difference(actual_hash, expected_hash),
      }
    end

    # Expects two hashes, with values as counts for keys.
    # Produces an array of differences with elements repeated if needed.
    private def hash_count_difference(first, second)
      # Subtract the number of occurrences from the other array.
      # A duplicate hash is used here because the original can't be modified,
      # since it there's a two-way comparison.
      #
      # Then reject elements that have zero (or less) occurrences.
      # Lastly, expand to the correct number of elements.
      first.map do |element, count|
        if second_count = second[element]?
          {element, count - second_count}
        else
          {element, count}
        end
      end.reject do |(_, count)|
        count <= 0
      end.flat_map do |(element, count)|
        Array.new(count, element)
      end
    end

    private def unexpected(value, label)
      raise "#{label} is not a collection (must respond to `#to_a`). #{label}: #{value.inspect}"
    end
  end
end
