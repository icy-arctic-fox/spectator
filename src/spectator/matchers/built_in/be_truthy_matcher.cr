require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeTruthyMatcher
    include Matchable

    def description
      "be truthy"
    end

    def matches?(actual_value)
      !!actual_value
    end

    def does_not_match?(actual_value)
      !actual_value
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be truthy"
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to be falsy"
    end
  end
end
