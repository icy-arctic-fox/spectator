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
      differences = compare_arrays(expected_elements, actual_elements)

      if differences.empty?
        # Contents are identical.
        SuccessfulMatchData.new(match_data_description(actual))
      else
        difference_string = differences.map do |difference|
          "[#{difference[:index]}] expected: #{difference[:expected].inspect}, got: #{difference[:actual].inspect}"
        end.join("\n")
        # Content differs.
        FailedMatchData.new(match_data_description(actual), "#{actual.label} does not contain exactly #{expected.label}",
          expected: expected_elements.inspect,
          actual: actual_elements.inspect,
          differences: difference_string,
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

      if arrays_equal?(expected_elements, actual_elements)
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

    # Compares two arrays to determine whether they contain the same elements, in the same order.
    # Returns an array of mismatched elements.
    private def compare_arrays(expected_array, actual_array : Array(ActualType)) forall ActualType
      differences = [] of {index: Int32, expected: ExpectedType | Nil, actual: ActualType | Nil}

      min_length = expected_array.size < actual_array.size ? expected_array.size : actual_array.size
      min_length.times do |index|
        expected = expected_array[index]
        actual = actual_array[index]
        next if expected == actual
        differences << {index: index, expected: expected, actual: actual}
      end

      if expected_array.size > actual_array.size
        (expected_array.size - actual_array.size).times do |index|
          differences << {index: index + actual_array.size, expected: expected_array[index + actual_array.size], actual: nil}
        end
      elsif expected_array.size < actual_array.size
        (actual_array.size - expected_array.size).times do |index|
          differences << {index: index + expected_array.size, expected: nil, actual: actual_array[index + expected_array.size]}
        end
      end

      differences
    end

    # Compares two arrays to determine whether they contain the same elements.
    private def arrays_equal?(expected_array, actual_array)
      return false if expected_array.size != actual_array.size

      expected_array.zip(actual_array) do |expected, actual|
        return false unless expected == actual
      end

      true
    end

    private def unexpected(value, label)
      raise "#{label} is not a collection (must respond to `#to_a`). #{label}: #{value.inspect}"
    end
  end
end
