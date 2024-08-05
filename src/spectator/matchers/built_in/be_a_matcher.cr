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

    def failure_message(actual_value)
      <<-MESSAGE
       Expected: #{actual_value.pretty_inspect}
        to be a: #{T}
      but was a: #{actual_value.class}
      MESSAGE
    end

    def format_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << " Expected: "
      format_description_of(printer, actual_value)
      printer.puts

      printer << "  to be a: "
      format_description_of(printer, T)
      printer.puts

      printer << "but was a: "
      format_description_of(printer, actual_value.class)
    end

    def negated_failure_message(actual_value)
      <<-MESSAGE
         Expected: #{actual_value.pretty_inspect}
      not to be a: #{T}#{" (#{actual_value.class} is a sub-type of #{T})" if actual_value.class != T}
      MESSAGE
    end
  end
end
