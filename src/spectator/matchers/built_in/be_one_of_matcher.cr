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

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "    Expected: " << description_of(actual_value) << EOL
      printer << "to be one of: " << description_of(@expected)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "        Expected: " << description_of(actual_value) << EOL
      printer << "not to be one of: " << description_of(@expected)
    end
  end
end
