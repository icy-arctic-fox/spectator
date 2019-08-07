require "./failed_match_data"
require "./matcher"
require "./successful_match_data"
require "./unordered_array_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another and in the same order.
  struct ArrayMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(Enumerable(ExpectedType)))
    end

    def description
      "contains exactly #{expected.label}"
    end

    def match(actual)
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a
      index = compare_arrays(expected_elements, actual_elements)

      case index
      when true # Contents are identical.
        SuccessfulMatchData.new
      when false # Size differs.
        failed_size_mismatch(expected_elements, actual_elements, actual.label)
      else # Content differs.
        failed_content_mismatch(expected_elements, actual_elements, index, actual.label)
      end
    end

    def negated_match(actual)
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a

      case compare_arrays(expected_elements, actual_elements)
      when true # Contents are identical.
        failed_content_identical(expected_elements, actual_elements, actual.label)
      when false # Size differs.
        SuccessfulMatchData.new
      else # Contents differ.
        SuccessfulMatchData.new
      end
    end

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

    private def failed_size_mismatch(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (size mismatch)",
        expected: expected_elements.inspect,
        actual: actual_elements.inspect,
        "expected size": expected_elements.size.to_s,
        "actual size": actual_elements.size.to_s
      )
    end

    private def failed_content_mismatch(expected_elements, actual_elements, index, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (element mismatch)",
        expected: expected_elements[index].inspect,
        actual: actual_elements[index].inspect,
        index: index.to_s
      )
    end

    private def failed_content_identical(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual.label} contains exactly #{expected.label}",
        expected: "Not #{expected_elements.inspect}",
        actual: actual_elements.inspect
      )
    end
  end
end
