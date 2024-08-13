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

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be negative"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be negative"
    end
  end
end
