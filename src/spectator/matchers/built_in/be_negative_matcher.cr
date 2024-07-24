module Spectator::Matchers::BuiltIn
  struct BeNegativeMatcher
    def matches?(actual_value) : Bool
      actual_value.responds_to?(:negative?) && actual_value.negative?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be negative"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be negative"
    end
  end
end
