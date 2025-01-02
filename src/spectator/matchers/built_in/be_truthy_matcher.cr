require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeTruthyMatcher
    include Matchable

    def matches?(actual_value)
      !!actual_value
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be truthy"
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to be falsy"
    end

    def to_s(io : IO) : Nil
      io << "be truthy"
    end
  end
end
