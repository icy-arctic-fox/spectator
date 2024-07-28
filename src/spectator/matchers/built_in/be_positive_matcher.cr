module Spectator::Matchers::BuiltIn
  struct BePositiveMatcher
    def matches?(actual_value)
      actual_value.responds_to?(:positive?) && actual_value.positive?
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be positive"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} not to be positive"
    end
  end
end
