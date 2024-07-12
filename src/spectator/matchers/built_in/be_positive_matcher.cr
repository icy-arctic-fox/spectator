require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BePositiveMatcher < Matcher
    def matches?(actual_value) : Bool
      actual_value.responds_to?(:positive?) && actual_value.positive?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be positive"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be positive"
    end
  end
end
