require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeEmptyMatcher
    include Matchable

    def description
      "be empty"
    end

    def matches?(actual_value)
      (actual_value.responds_to?(:empty?) && actual_value.empty?) ||
        (actual_value.responds_to?(:size) && actual_value.size == 0)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be empty"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be empty"
    end
  end
end
