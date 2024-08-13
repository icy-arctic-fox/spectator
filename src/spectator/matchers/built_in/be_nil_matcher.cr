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

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be nil"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to be nil"
    end
  end
end
