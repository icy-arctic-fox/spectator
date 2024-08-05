require "./indent"
require "./printer"

module Spectator::Formatters
  class PlainPrinter < Printer
    include Indent

    def print_value(& : IO ->) : Nil
      yield io
    end

    def print_type(& : IO ->) : Nil
      yield io
    end

    def print_title(style : Style = :none, & : IO ->) : Nil
      yield io
    end

    def print_label(style : Style = :none, & : IO ->) : Nil
      yield io
    end

    def print_inline_label(label : String, style : Style = :none, padding : Int = 0, &) : Nil
      indent(padding) do
        print_indent
        io << label
        io << ' '
        indent(label.size + padding + 1) { yield }
      end
    end

    def print_code(code : String) : Nil
      io.puts code
    end
  end
end
