require "crystal/syntax_highlighter/colorize"
require "colorize"
require "./indent"
require "./printer"

module Spectator::Formatters
  class TerminalPrinter < Printer
    include Indent

    private property style : Style = :none

    def <<(object) : self
      print_indented(io, colorize_style(object))
      self
    end

    def print(*objects) : Nil
      colorize_style.surround(io) do
        print_indented(io, *objects)
      end
    end

    def puts(*objects) : Nil
      colorize_style.surround(io) do
        puts_indented(io, *objects)
      end
    end

    def title(text : String) : Nil
      emphasized_colorize_style.surround(io) do
        print_indented(io, ' ', text, ' ')
      end
      puts_indented(io)
      puts_indented(io)
    end

    def label(label : String, *, padding : Int = 0, & : self ->) : Nil
      puts_indented(io) unless newline?
      emphasized_colorize_style.surround(io) do
        print_indented(io, " " * padding, label)
      end
      io << ' '
      indent(padding + label.size + 1) { yield self }
    end

    def value(value) : Nil
      Colorize.with.bold.surround(io) do
        print_indented(io, value.inspect)
      end
    end

    def type(type) : Nil
      Colorize.with.bold.cyan.surround(io) do
        print_indented(io, type)
      end
    end

    def code(code : String) : Nil
      code = reduce_indent(code)
      highlighted = highlight_syntax(code)
      print_indented(io, highlighted)
    end

    def with_style(style : Style, & : self ->) : Nil
      previous_style = self.style
      begin
        self.style = style
        yield self
      ensure
        self.style = previous_style
      end
    end

    private def highlight_syntax(code : String) : String
      String.build do |io|
        Crystal::SyntaxHighlighter::Colorize.new(io).tap do |highlighter|
          highlighter.colors = {
            :comment           => :dark_gray,
            :number            => :magenta,
            :symbol            => :magenta,
            :char              => :green,
            :string            => :green,
            :interpolation     => :green,
            :const             => :cyan,
            :operator          => :white,
            :ident             => :blue,
            :keyword           => :blue,
            :primitive_literal => :magenta,
            :self              => :blue,
            :unknown           => :white,
          } of Crystal::SyntaxHighlighter::TokenType => Colorize::Color
        end.highlight(code)
      end
    end

    private def colorize_style(object = nil)
      base = object.colorize
      case style
      in .none?    then base
      in .info?    then base.blue
      in .success? then base.green
      in .warning? then base.yellow
      in .error?   then base.red
      end
    end

    private def emphasized_colorize_style(object = nil)
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
