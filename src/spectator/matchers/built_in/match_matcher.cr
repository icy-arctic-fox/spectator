require "../matchable"

module Spectator::Matchers::BuiltIn
  struct MatchMatcher(T)
    include Matchable

    def description
      "match #{@expected_value}"
    end

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      !!(actual_value =~ @expected_value)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to match: "
      printer.description_of(@expected_value)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "    Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to match: "
      printer.description_of(@expected_value)
    end
  end
end
