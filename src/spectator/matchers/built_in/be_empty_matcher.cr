require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeEmptyMatcher
    include Matchable

    def description
      "be empty"
    end

    def matches?(actual_value)
      (actual_value.responds_to?(:empty?) && actual_value.empty?) ||
        (actual_value.responds_to?(:size) && actual_value.size == 0)
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be empty"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be empty"
    end
  end
end
