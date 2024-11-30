require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeInstanceOfMatcher(T)
    include Matchable

    def description
      "be a #{T}"
    end

    def matches?(actual_value)
      actual_value.class == T
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      if actual_value.is_a?(T)
        printer << " Expected: " << description_of(actual_value) << EOL
        printer << "  to be a: " << description_of(T) << EOL
        printer << "but was a: " << description_of(actual_value.class) << EOL << EOL

        printer << description_of(actual_value.class) << " is a sub-type of " << description_of(T) << '.' << EOL

        printer.puts "Using `be_instance_of` ensures the type matches EXACTLY."
        printer.print "If you want to match sub-types, use `be_a` instead."
      else
        printer << " Expected: " << description_of(actual_value) << EOL
        printer << "  to be a: " << description_of(T) << EOL
        printer << "but was a: " << description_of(actual_value.class)
      end
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "   Expected: " << description_of(actual_value) << EOL
      printer << "not to be a: " << description_of(T)
    end
  end
end
