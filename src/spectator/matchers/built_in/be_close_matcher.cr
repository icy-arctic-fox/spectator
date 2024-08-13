require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeCloseMatcher(T, D)
    include Matchable

    def description
      "be within #{@delta} of #{@expected_value}"
    end

    def initialize(@expected_value : T, @delta : D)
    end

    def matches?(actual_value)
      actual_value <= @expected_value + @delta &&
        actual_value >= @expected_value - @delta
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "    Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be within: "
      printer.description_of(@expected_value)
      printer << " ± "
      printer.description_of(@delta)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "     Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be outside: "
      printer.description_of(@expected_value)
      printer << " ± "
      printer.description_of(@delta)
    end
  end
end
