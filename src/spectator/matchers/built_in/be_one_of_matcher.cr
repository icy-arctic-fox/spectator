require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeOneOfMatcher(T)
    include Matchable

    def description
      "be one of #{@expected}"
    end

    def initialize(@expected : T)
      {% raise "Expected type must be a Tuple" unless T < Tuple %}
    end

    def matches?(actual_value)
      @expected.includes?(actual_value)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "    Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be one of: "
      printer.description_of(@expected)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "        Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to be one of: "
      printer.description_of(@expected)
    end
  end
end
