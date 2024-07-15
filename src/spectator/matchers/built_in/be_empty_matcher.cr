module Spectator::Matchers::BuiltIn
  struct BeEmptyMatcher
    def matches?(actual_value) : Bool
      (actual_value.responds_to?(:empty?) && actual_value.empty?) ||
        (actual_value.responds_to?(:size) && actual_value.size == 0)
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be empty"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be empty"
    end
  end
end
