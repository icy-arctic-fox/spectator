require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BeNaNMatcher < Matcher
    def matches?(actual_value) : Bool
      actual_value.responds_to?(:nan?) && actual_value.nan?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be NaN"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be NaN"
    end
  end
end
