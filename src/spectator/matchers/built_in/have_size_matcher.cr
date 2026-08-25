require "../matchable"

module Spectator::Matchers::BuiltIn
  struct HaveSizeMatcher(T)
    include Matchable

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      if actual_value.responds_to?(:size)
        actual_value.size == @expected_value
      else
        false
      end
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value) << EOL
      printer << " to have: " << description_of(@expected_value) << " elements" << EOL
      if actual_value.responds_to?(:size)
        printer << " but has: " << description_of(actual_value.size) << " elements"
      else
        printer << "but has no size"
      end
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "   Expected: " << description_of(actual_value) << EOL
      printer << "not to have: " << description_of(@expected_value) << " elements"
    end

    def to_s(io : IO) : Nil
      io << "have " << @expected_value << " elements"
    end
  end
end
