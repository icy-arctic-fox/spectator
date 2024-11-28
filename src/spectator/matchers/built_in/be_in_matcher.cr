require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeInMatcher(T)
    include Matchable

    def description
      "be in #{@expected_value}"
    end

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      actual_value.in?(@expected_value)
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value) << EOL
      printer << "to be in: " << description_of(@expected_value)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "    Expected: " << description_of(actual_value) << EOL
      printer << "not to be in: " << description_of(@expected_value)
    end
  end
end
