require "../formatters/plain_printer"
require "./formatting"

module Spectator::Matchers
  module Printable
    abstract def failure_message(printer : FormattingPrinter, actual_value) : Nil

    def failure_message(printer : FormattingPrinter, &) : Nil
      failure_message(printer, yield)
    end

    abstract def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil

    def negated_failure_message(printer : FormattingPrinter, &) : Nil
      negated_failure_message(printer, yield)
    end

    def failure_message(actual_value)
      Printable.build_message do |printer|
        failure_message(printer, actual_value)
      end
    end

    def failure_message(&)
      Printable.build_message do |printer|
        failure_message(printer, yield)
      end
    end

    def negated_failure_message(actual_value)
      Printable.build_message do |printer|
        negated_failure_message(printer, actual_value)
      end
    end

    def negated_failure_message(&)
      Printable.build_message do |printer|
        negated_failure_message(printer, yield)
      end
    end

    def self.build_message(&)
      String.build do |io|
        printer = Formatters::PlainPrinter.new(io)
        yield FormattingPrinter.new(printer)
      end
    end
  end
end
