require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeZeroMatcher
    include Matchable

    def description
      "be zero"
    end

    def matches?(actual_value)
      (actual_value.responds_to?(:zero?) && actual_value.zero?) ||
        actual_value == 0
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be zero"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be zero"
    end
  end
end
