require "../matchable"

module Spectator::Matchers::BuiltIn
  struct ContainMatcher(T)
    include Matchable

    def description
      "contain #{@expected}"
    end

    def initialize(@expected : T)
      {% raise "Expected type must be a Tuple" unless T < Tuple %}
    end

    def matches?(actual_value)
      @expected.all? { |item| actual_value.includes?(item) }
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "  Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to contain: "
      printer.description_of(@expected)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "      Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to contain: "
      printer.description_of(@expected)
    end
  end
end
