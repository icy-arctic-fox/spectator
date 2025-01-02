require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeNaNMatcher
    include Matchable

    def matches?(actual_value)
      actual_value.responds_to?(:nan?) && actual_value.nan?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be NaN"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be NaN"
    end

    def to_s(io : IO) : Nil
      io << "be NaN"
    end
  end
end
