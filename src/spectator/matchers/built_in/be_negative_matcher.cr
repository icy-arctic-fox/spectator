require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeNegativeMatcher
    include Matchable

    def description
      "be negative"
    end

    def matches?(actual_value)
      actual_value.responds_to?(:negative?) && actual_value.negative?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be negative"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be negative"
    end
  end
end
