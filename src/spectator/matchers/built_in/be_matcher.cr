require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeMatcher(T)
    include Matchable

    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      expected_value = @expected_value
      if expected_value.is_a?(Reference) && actual_value.is_a?(Reference)
        # Both are references, check if they're the same object.
        actual_value.same?(expected_value)
      elsif expected_value.class == actual_value.class
        # Both are the same type, check if they're equal.
        actual_value == expected_value
      else
        # They're different types, so they can't be the same.
        false
      end
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << inspect_value(actual_value) << EOL
      printer << "   to be: " << inspect_value(@expected_value)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << " Expected: " << inspect_value(actual_value) << EOL
      printer << "not to be: " << inspect_value(@expected_value)
    end

    def to_s(io : IO) : Nil
      io << "be " << inspect_value(@expected_value)
    end
  end
end
