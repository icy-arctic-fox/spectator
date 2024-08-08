require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeAMatcher(T)
    include Matchable

    def description
      "be a #{T}"
    end

    def matches?(actual_value)
      actual_value.is_a?(T)
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << " Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "  to be a: "
      printer.description_of(T)
      printer.puts

      printer << "but was a: "
      printer.description_of(actual_value.class)
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "   Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "not to be a: "
      printer.description_of(T)
      printer.puts

      return if actual_value.class == T
      printer.description_of(actual_value.class)
      printer << " is a sub-type of "
      printer.description_of(T)
    end
  end
end
