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

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      if actual_value.is_a?(T)
        printer << " Expected: "
        printer.description_of(actual_value)
        printer.puts

        printer << "  to be a: "
        printer.description_of(T)
        printer.puts

        printer << "but was a: "
        printer.description_of(actual_value.class)
        printer.puts
        printer.puts

        printer.description_of(actual_value.class)
        printer << " is a sub-type of "
        printer.description_of(T)
        printer.puts '.'

        printer.puts "Using `be_instance_of` ensures the type matches EXACTLY."
        printer.print "If you want to match sub-types, use `be_a` instead."
      else
        printer << " Expected: "
        printer.description_of(actual_value)
        printer.puts

        printer << "  to be a: "
        printer.description_of(T)
        printer.puts

        printer << "but was a: "
        printer.description_of(actual_value.class)
      end
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "   Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to be a: "
      printer.description_of(T)
    end
  end
end
