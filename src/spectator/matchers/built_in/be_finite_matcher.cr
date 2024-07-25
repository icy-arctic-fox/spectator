module Spectator::Matchers::BuiltIn
  struct BeFiniteMatcher
    def matches?(actual_value) : Bool
      !!((actual_value.responds_to?(:finite?) && actual_value.finite?) ||
        (actual_value.is_a?(Number) &&
          actual_value != Float64::INFINITY && actual_value != -Float64::INFINITY))
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be finite"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be infinite"
    end
  end
end
