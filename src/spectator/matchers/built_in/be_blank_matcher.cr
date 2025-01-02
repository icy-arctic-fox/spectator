require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeBlankMatcher
    include Matchable

    def matches?(actual_value)
      actual_value.responds_to?(:blank?) && actual_value.blank?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be blank"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value : String) : Nil
      printer << "Expected string not to be blank"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be blank"
    end

    def to_s(io : IO) : Nil
      io << "be blank"
    end
  end
end
