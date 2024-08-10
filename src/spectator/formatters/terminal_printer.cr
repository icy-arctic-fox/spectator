require "crystal/syntax_highlighter/colorize"
require "colorize"
require "./indent"
require "./printer"

module Spectator::Formatters
  class TerminalPrinter < Printer
    include Indent

    private getter style : Style = :none

    def <<(object) : self
      print_indented(io, object)
      self
    end

    def print(*objects) : Nil
      print_indented(io, *objects)
    end

    def puts(*objects) : Nil
      puts_indented(io, *objects)
    end

    def title(text : String) : Nil
      puts_indented(io)
      emphasized_colorize_style(style).surround(io) do
        print_indented(io, ' ', text, ' ')
      end
      puts_indented(io)
      puts_indented(io)
    end

    def label(label : String, *, padding : Int = 0, & : self ->) : Nil
      puts_indented(io)
      emphasized_colorize_style(style).surround(io) do
        print_indented(io, " " * padding, label, ' ')
      end
      indent(label.size + 1) do
        yield self
      end
    end

    def value(value) : Nil
      Colorize.with.bold.surround(io) do
        print_indented(io, value)
      end
    end

    def type(type) : Nil
      Colorize.with.bold.cyan.surround(io) do
        print_indented(io, type)
      end
    end

    def code(code : String) : Nil
      lines = code.lines(false)
      min_code_indent = lines.min_of { |line| indent_size(line) }
      lines.map! { |line| line[min_code_indent..] }
      code = lines.join
      highlighted = syntax_highlighter.highlight(code)
      puts_indented(io, highlighted)
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

    private getter syntax_highlighter : Crystal::SyntaxHighlighter do
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
      end
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
