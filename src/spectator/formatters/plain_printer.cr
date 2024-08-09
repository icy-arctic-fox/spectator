require "./indent"
require "./printer"

module Spectator::Formatters
  class PlainPrinter < Printer
    include Indent

    def puts(*objects, style : Style) : Nil
      puts *objects # Uses Indent#puts
    end

    def print(*objects, style : Style) : Nil
      print *objects # Uses Indent#print
    end

    def print_value(& : IO ->) : Nil
      print_indent
      yield io
    end

    def print_type(& : IO ->) : Nil
      print_indent
      yield io
    end

    def print_title(style : Style = :none, & : IO ->) : Nil
      print_indent
      yield io
    end

    def print_label(style : Style = :none, & : IO ->) : Nil
      print_indent
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
      print_indent
      io.puts code
    end
  end
end
