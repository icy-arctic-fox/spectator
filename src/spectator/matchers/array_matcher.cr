require "./failed_match_data"
require "./matcher"
require "./successful_match_data"
require "./unordered_array_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another and in the same order.
  struct ArrayMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(@expected : TestValue(ExpectedType))
    end

    def description
      "contains exactly #{expected.label}"
    end

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

    def in_order
      self
    end

    def in_any_order
      UnorderedArrayMatcher.new(expected)
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
      FailedMatchData.new("#{actual_label} contains exactly #{expected.label}",
        expected: "Not #{expected_elements.inspect}",
        actual: actual_elements.inspect
      )
    end
  end
end
