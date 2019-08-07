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
      if expected_elements.size == actual_elements.size
        index = 0
        expected_elements.zip(actual_elements) do |expected_element, actual_element|
          unless expected_element == actual_element
            return FailedMatchData.new("#{actual.label} does not contain exactly #{expected.label} (element mismatch)",
              [
                LabeledValue.new(expected_element.inspect, "expected"),
                LabeledValue.new(actual_element.inspect, "actual"),
                LabeledValue.new(index.to_s, "index"),
              ])
          end
          index += 1
        end
        # Success.
        SuccessfulMatchData.new
      else
        # Size mismatch.
        FailedMatchData.new("#{actual.label} does not contain exactly #{expected.label} (size mismatch)",
          [
            LabeledValue.new(expected_elements.inspect, "expected"),
            LabeledValue.new(actual_elements.inspect, "actual"),
            LabeledValue.new(expected_elements.size, "expected size"),
            LabeledValue.new(actual_elements.size, "actual size"),
          ])
      end
    end

    def negated_match(actual)
      actual_elements = actual.value.to_a
      expected_elements = expected.value.to_a
      if expected_elements.size == actual_elements.size
        index = 0
        expected_elements.zip(actual_elements) do |expected_element, actual_element|
          return SuccessfulMatchData.new unless expected_element == actual_element
          index += 1
        end
        FailedMatchData.new("#{actual.label} contains exactly #{expected.label}",
          [
            LabeledValue.new("Not #{expected_elements.inspect}", "expected"),
            LabeledValue.new(actual_elements.inspect, "actual"),
          ])
      else
        SuccessfulMatchData.new
      end
    end
  end
end
