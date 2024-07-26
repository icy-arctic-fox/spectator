module Spectator::Matchers::BuiltIn
  struct BeInfiniteMatcher
    def matches?(actual_value) : Bool
      !!((actual_value.responds_to?(:infinite?) && actual_value.infinite?) ||
        (actual_value.is_a?(Number) &&
          (actual_value == Float64::INFINITY || actual_value == -Float64::INFINITY)))
    end

    def does_not_match?(actual_value) : Bool
      !!((actual_value.responds_to?(:finite?) && actual_value.finite?) ||
        (actual_value.is_a?(Number) &&
          actual_value != Float64::INFINITY && actual_value != -Float64::INFINITY))
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be infinite"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be finite"
    end
  end
end
