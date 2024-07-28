module Spectator::Matchers::BuiltIn
  struct BeZeroMatcher
    def matches?(actual_value)
      (actual_value.responds_to?(:zero?) && actual_value.zero?) ||
        actual_value == 0
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be zero"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} not to be zero"
    end
  end
end
