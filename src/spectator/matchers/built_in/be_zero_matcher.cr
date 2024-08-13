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

    def does_not_match?(actual_value)
      !matches?(actual_value)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be zero"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be zero"
    end
  end
end
