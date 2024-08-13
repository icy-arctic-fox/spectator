require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeInMatcher(T)
    include Matchable

    def description
      "be in #{@expected_value}"
    end

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      actual_value.in?(@expected_value)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be in: "
      printer.description_of(@expected_value)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "    Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to be in: "
      printer.description_of(@expected_value)
    end
  end
end
