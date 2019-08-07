require "./value_matcher"
require "./unordered_array_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another and in the same order.
  struct ArrayMatcher(ExpectedType) < ValueMatcher(Enumerable(ExpectedType))
    def description
      "contains exactly #{expected.label}"
    end

    private def failure_message(actual)
      {% raise "This method should never be called" %}
    end

    private def failure_message_when_negated(actual)
      {% raise "This method should never be called" %}
    end

    private def match?(actual)
      {% raise "This method should never be called" %}
    end

    private def does_not_match?(actual)
      {% raise "This method should never be called" %}
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

    def failed_size_mismatch(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (size mismatch)",
        [
          LabeledValue.new(expected_elements.inspect, "expected"),
          LabeledValue.new(actual_elements.inspect, "actual"),
          LabeledValue.new(expected_elements.size, "expected size"),
          LabeledValue.new(actual_elements.size, "actual size"),
        ])
    end

    def failed_content_mismatch(expected_elements, actual_elements, index, actual_label)
      FailedMatchData.new("#{actual_label} does not contain exactly #{expected.label} (element mismatch)",
        [
          LabeledValue.new(expected_elements[index].inspect, "expected"),
          LabeledValue.new(actual_elements[index].inspect, "actual"),
          LabeledValue.new(index.to_s, "index"),
        ])
    end

    def failed_content_identical(expected_elements, actual_elements, actual_label)
      FailedMatchData.new("#{actual.label} contains exactly #{expected.label}",
        [
          LabeledValue.new("Not #{expected_elements.inspect}", "expected"),
          LabeledValue.new(actual_elements.inspect, "actual"),
        ])
    end
  end
end
