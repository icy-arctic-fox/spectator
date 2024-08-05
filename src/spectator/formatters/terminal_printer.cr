require "crystal/syntax_highlighter/colorize"
require "colorize"
require "./indent"
require "./printer"

module Spectator::Formatters
  class TerminalPrinter < Printer
    include Indent

    def puts(*objects, style : Style) : Nil
      colorize_style(style).surround(io) do
        puts *objects # Uses Indent#puts
      end
    end

    def print(*objects, style : Style) : Nil
      print_indent
      colorize_style(style).surround(io) do
        print *objects # Uses Indent#print
      end
    end

    def print_value(& : IO ->) : Nil
      print_indent
      Colorize.with.bold.surround(io) do
        yield io
      end
    end

    def print_type(& : IO ->) : Nil
      print_indent
      Colorize.with.bold.cyan.surround(io) do
        yield io
      end
    end

    def print_title(style : Style = :none, & : IO ->) : Nil
      print_indent
      emphasized_colorize_style(style).surround(io) do
        io << ' '
        yield io
        io << ' '
      end
      puts
    end

    def print_label(style : Style = :none, & : IO ->) : Nil
      print_indent
      colorize_style(style).surround(io) do
        yield io
      end
    end

    def print_inline_label(label : String, style : Style = :none, padding : Int = 0, &) : Nil
      indent(padding) do
        emphasized_colorize_style(style, label).surround(io) do
          print_indent
          io << label
        end
        io << ' '
        indent(label.size + 1) { yield }
      end
    end

    def print_code(code : String) : Nil
      indent = " " * indent_amount
      indented_code = code.gsub('\n', "\n#{indent}")
      Crystal::SyntaxHighlighter::Colorize.highlight(io, indented_code)
      io.puts unless code.ends_with?("\n")
    end

    private def colorize_style(style : Style, object = nil)
      base = object.colorize
      case style
      in .none?    then base
      in .info?    then base.blue
      in .success? then base.green
      in .warning? then base.yellow
      in .error?   then base.red
      end
    end

    private def emphasized_colorize_style(style : Style, object = nil)
      base = object.colorize
      case style
      in .none?    then base.black.on_white
      in .info?    then base.on_blue
      in .success? then base.on_green
      in .warning? then base.on_yellow
      in .error?   then base.on_red
      end.bold
    end
  end
end
