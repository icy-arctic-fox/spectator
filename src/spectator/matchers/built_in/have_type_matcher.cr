require "../matchable"

module Spectator::Matchers::BuiltIn
  struct HaveTypeMatcher(T)
    include Matchable

    def matches?(actual_value)
      typeof(actual_value) == T
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << " Expected: " << description_of(actual_value) << EOL
      printer << "  to be a: " << description_of(T) << EOL
      printer << "but was a: " << description_of(typeof(actual_value))

      if typeof(actual_value) < T
        printer.puts
        printer << EOL << description_of(typeof(actual_value)) << " is a sub-type of " << description_of(T) << EOL
        printer.puts "Using `have_type` ensures the type matches an EXACT, compile-time type."
        printer.print "If you want to match sub-types, use `be_a` instead."
      end
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "   Expected: " << description_of(actual_value) << EOL
      printer << "not to be a: " << description_of(T)
    end

    def to_s(io : IO) : Nil
      io << "have type compile-time type " << T
    end
  end
end
