require "../matchable"

module Spectator::Matchers::BuiltIn
  struct RespondToMatcher(NT)
    include Matchable

    def description
      "respond to #{method_name}"
    end

    def matches?(actual_value)
      {% begin %}
        actual_value.responds_to?({{NT.keys.first.symbolize}})
      {% end %}
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " to respond to " << method_name
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "Expected "
      printer.description_of(actual_value)
      printer << " not to respond to " << method_name
    end

    private def method_name : Symbol
      {{NT.keys.first.symbolize}}
    end
  end
end
