module Spectator::Matchers::BuiltIn
  struct BeNaNMatcher
    def matches?(actual_value)
      actual_value.responds_to?(:nan?) && actual_value.nan?
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be NaN"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} not to be NaN"
    end
  end
end
