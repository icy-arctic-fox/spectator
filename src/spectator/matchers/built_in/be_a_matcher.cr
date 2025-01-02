require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeAMatcher(T)
    include Matchable

    def matches?(actual_value)
      actual_value.is_a?(T)
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << " Expected: " << description_of(actual_value) << EOL
      printer << "  to be a: " << description_of(T) << EOL
      printer << "but was a: " << description_of(actual_value.class)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "   Expected: " << description_of(actual_value) << EOL
      printer << "not to be a: " << description_of(T)
      if actual_value.class < T
        printer << EOL << description_of(actual_value.class) << " is a sub-type of " << description_of(T)
      end
    end

    def to_s(io : IO) : Nil
      io << "be a " << T
    end
  end
end
