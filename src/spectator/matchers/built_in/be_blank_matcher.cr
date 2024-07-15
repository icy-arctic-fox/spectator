module Spectator::Matchers::BuiltIn
  struct BeBlankMatcher
    def matches?(actual_value) : Bool
      (actual_value.responds_to?(:blank?) && actual_value.blank?) ||
        (actual_value.responds_to?(:empty?) && actual_value.empty?) ||
        actual_value == ""
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be blank"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be blank"
    end
  end
end
