require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BePresentMatcher
    include Matchable

    def description
      "be present"
    end

    def matches?(actual_value)
      (actual_value.responds_to?(:present?) && actual_value.present?) ||
        (actual_value.responds_to?(:empty?) && !actual_value.blank?) ||
        !actual_value.nil?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be present"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be present"
    end
  end
end
