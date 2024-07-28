module Spectator::Matchers::BuiltIn
  struct BeInfiniteMatcher
    def matches?(actual_value)
      if actual_value.responds_to?(:infinite?)
        # The `infinite?` method returns 0 for finite values, -1 for negative infinity, and 1 for positive infinity.
        # However, since it's a predicate method, truthiness is checked as well.
        is_infinite = actual_value.infinite?
        !!is_infinite && is_infinite != 0
      elsif actual_value.is_a?(Number)
        actual_value == Float64::INFINITY || actual_value == -Float64::INFINITY
      else
        false
      end
    end

    def does_not_match?(actual_value)
      (actual_value.responds_to?(:finite?) && actual_value.finite?) ||
        (actual_value.is_a?(Number) &&
          actual_value != Float64::INFINITY && actual_value != -Float64::INFINITY)
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be infinite"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be finite"
    end
  end
end
