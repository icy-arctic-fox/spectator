module Spectator::Matchers::BuiltIn
  struct BeEmptyMatcher
    def matches?(actual_value)
      (actual_value.responds_to?(:empty?) && actual_value.empty?) ||
        (actual_value.responds_to?(:size) && actual_value.size == 0)
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be empty"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} not to be empty"
    end
  end
end
