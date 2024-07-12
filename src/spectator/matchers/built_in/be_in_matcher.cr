require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BeInMatcher(T) < Matcher
    def initialize(@expected_value : T)
    end

    def matches?(actual_value) : Bool
      actual_value.in?(@expected_value)
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be in #{@expected_value.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be in #{@expected_value.pretty_inspect}"
    end
  end
end
