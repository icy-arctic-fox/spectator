module Spectator::Matchers::BuiltIn
  struct BeBetweenMatcher(B, E)
    def initialize(@min : B, @max : E)
    end

    def matches?(actual_value) : Bool
      actual_value >= @min && actual_value <= @max
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be between #{@min.pretty_inspect} and #{@max.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be between #{@min.pretty_inspect} and #{@max.pretty_inspect}"
    end
  end
end
