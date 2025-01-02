require "../matchable"

module Spectator::Matchers::BuiltIn
  struct MatchMatcher(T)
    include Matchable

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      !!(actual_value =~ @expected_value)
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value) << EOL
      printer << "to match: " << description_of(@expected_value)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "    Expected: " << description_of(actual_value) << EOL
      printer << "not to match: " << description_of(@expected_value)
    end

    def to_s(io : IO) : Nil
      io << "match " << description_of(@expected_value)
    end
  end
end
