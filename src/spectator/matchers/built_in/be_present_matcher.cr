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

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be present"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be present"
    end
  end
end
