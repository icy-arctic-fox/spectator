require "./matcher"

module Spectator::Matchers
  # Matcher that tests a value is of a specified type.
  # The values are compared with the `Object#is_a?` method.
  struct TypeMatcher(Expected) < StandardMatcher
    private def match?(actual)
      actual.value.is_a?(Expected)
    end

    def description
      "is as #{Expected}"
    end

    private def failure_message(actual)
      "#{actual.label} is not a #{Expected}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is a #{Expected}"
    end

    private def values(actual)
      {
        expected: Expected.to_s,
        actual:   actual.value.class.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: "Not #{Expected}",
        actual:   actual.value.class.inspect,
      }
    end
  end
end
