require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeNilMatcher
    include Matchable

    def description
      "be nil"
    end

    def matches?(actual_value)
      actual_value.nil?
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be nil"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to be nil"
    end
  end
end
