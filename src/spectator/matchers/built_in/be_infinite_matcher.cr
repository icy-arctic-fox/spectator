require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeInfiniteMatcher
    include Matchable

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

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be infinite"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be finite"
    end

    def to_s(io : IO) : Nil
      io << "be infinite"
    end
  end
end
