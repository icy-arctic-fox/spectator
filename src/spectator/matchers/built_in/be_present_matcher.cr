module Spectator::Matchers::BuiltIn
  struct BePresentMatcher
    def matches?(actual_value) : Bool
      (actual_value.responds_to?(:present?) && actual_value.present?) ||
        (actual_value.responds_to?(:empty?) && !actual_value.blank?) ||
        !actual_value.nil?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be present"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be present"
    end
  end
end
