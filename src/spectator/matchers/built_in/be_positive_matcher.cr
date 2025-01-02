require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BePositiveMatcher
    include Matchable

    def matches?(actual_value)
      actual_value.responds_to?(:positive?) && actual_value.positive?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be positive"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be positive"
    end

    def to_s(io : IO) : Nil
      io << "be positive"
    end
  end
end
