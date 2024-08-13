require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeNaNMatcher
    include Matchable

    def description
      "be NaN"
    end

    def matches?(actual_value)
      actual_value.responds_to?(:nan?) && actual_value.nan?
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be NaN"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be NaN"
    end
  end
end
