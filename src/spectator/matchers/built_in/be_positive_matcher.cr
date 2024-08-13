require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BePositiveMatcher
    include Matchable

    def description
      "be positive"
    end

    def matches?(actual_value)
      actual_value.responds_to?(:positive?) && actual_value.positive?
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be positive"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be positive"
    end
  end
end
