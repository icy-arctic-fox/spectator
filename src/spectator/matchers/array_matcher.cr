require "./failed_match_data"
require "./matcher"
require "./successful_match_data"
require "./unordered_array_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another and in the same order.
  struct ArrayMatcher(ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with an expected value.
    def initialize(@expected : TestValue(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "contains exactly #{expected.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a
      index = compare_arrays(expected_elements, actual_elements)

      case index
      when Int # Content differs.
        failed_content_mismatch(expected_elements, actual_elements, index, actual.label)
      when true # Contents are identical.
        SuccessfulMatchData.new
      else # Size differs.
        failed_size_mismatch(expected_elements, actual_elements, actual.label)
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a

      case compare_arrays(expected_elements, actual_elements)
      when Int # Contents differ.
        SuccessfulMatchData.new
      when true # Contents are identical.
        failed_content_identical(expected_elements, actual_elements, actual.label)
      else # Size differs.
        SuccessfulMatchData.new
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

    # Compares two arrays to determine whether they contain the same elements, and in the same order.
    # If the arrays are the same, then `true` is returned.
    # If they are different, `false` or an integer is returned.
    # `false` is returned when the sizes of the arrays don't match.
    # An integer is returned, that is the index of the mismatched elements in the arrays.
    private def compare_arrays(expected_elements, actual_elements)
      if expected_elements.size == actual_elements.size
        index = 0
        expected_elements.zip(actual_elements) do |expected_element, actual_element|
          return index unless expected_element == actual_element
          index += 1
        end
        true
      else
        false
      end
    end

    # Produces match data for a failure when the array sizes differ.
    private def failed_size_mismatch(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (size mismatch)",
        expected: expected_elements.inspect,
        actual: actual_elements.inspect,
        "expected size": expected_elements.size.to_s,
        "actual size": actual_elements.size.to_s
      )
    end

    # Produces match data for a failure when the array content is mismatched.
    private def failed_content_mismatch(expected_elements, actual_elements, index, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (element mismatch)",
        expected: expected_elements[index].inspect,
        actual: actual_elements[index].inspect,
        index: index.to_s
      )
    end

    # Produces match data for a failure when the arrays are identical, but they shouldn't be (negation).
    private def failed_content_identical(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual_label} contains exactly #{expected.label}",
        expected: "Not #{expected_elements.inspect}",
        actual: actual_elements.inspect
      )
    end
  end
end
