module Spectator::Matchers::BuiltIn
  struct BeBlankMatcher
    def matches?(actual_value) : Bool
      actual_value.responds_to?(:blank?) && actual_value.blank?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be blank"
    end

    def negated_failure_message(actual_value : String) : String
      "Expected string not to be blank"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be blank"
    end
  end
end
