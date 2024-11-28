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

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "  Expected: " << description_of(actual_value) << EOL
      printer << "to contain: " << description_of(@expected)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "      Expected: " << description_of(actual_value) << EOL
      printer << "not to contain: " << description_of(@expected)
    end
  end
end
