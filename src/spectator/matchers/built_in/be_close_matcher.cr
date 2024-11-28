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

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "    Expected: " << description_of(actual_value) << EOL
      printer << "to be within: " << description_of(@expected_value) << " ± " << description_of(@delta)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "     Expected: " << description_of(actual_value) << EOL
      printer << "to be outside: " << description_of(@expected_value) << " ± " << description_of(@delta)
    end
  end
end
