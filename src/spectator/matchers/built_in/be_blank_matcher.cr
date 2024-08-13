require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeBlankMatcher
    include Matchable

    def description
      "be blank"
    end

    def matches?(actual_value)
      actual_value.responds_to?(:blank?) && actual_value.blank?
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be blank"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value : String) : Nil
      printer << "Expected string not to be blank"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be blank"
    end
  end
end
