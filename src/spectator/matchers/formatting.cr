require "../formatters/printer"

module Spectator::Matchers
  module Formatting
    private def description_of(value)
      # TODO: Actually format the value.
      value.inspect
    end

    module Printable
      private getter! printer : Formatters::Printer

      def with_printer(printer : Formatters::Printer, & : self ->) : Nil
        previous = @printer
        begin
          @printer = printer
          yield self
        ensure
          @printer = previous
        end
      end

      def print(*objects) : Nil
        maybe_print_newline
        printer.print *objects
      end

      def puts(*objects) : Nil
        maybe_print_newline
        printer.puts *objects
      end

      def puts
        maybe_print_newline
        @pending_newline = true
        self
      end

      private def maybe_print_newline : Nil
        return unless @pending_newline
        printer.puts
        @pending_newline = false
      end

      def <<(object) : self
        maybe_print_newline
        printer << object
        self
      end

      private def description_of(value) : Nil
        maybe_print_newline
        printer.print_value do |io|
          value.inspect(io)
        end
      end

      private def description_of(value : T.class) : Nil forall T
        maybe_print_newline
        printer.print_type do |io|
          value.inspect(io)
        end
      end
    end
  end
end
