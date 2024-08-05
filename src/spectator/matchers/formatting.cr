require "../formatters/printer"

module Spectator::Matchers
  module Formatting
    private def description_of(value)
      # TODO: Actually format the value.
      value.inspect
    end

    private def format_description_of(printer : Formatters::Printer, value) : Nil
      printer.print_value do |io|
        value.inspect(io)
      end
    end

    private def format_description_of(printer : Formatters::Printer, value : T.class) : Nil forall T
      printer.print_type do |io|
        value.inspect(io)
      end
    end
  end
end
