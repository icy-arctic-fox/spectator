require "./indent"
require "./printer"

module Spectator::Formatters
  class PlainPrinter < Printer
    include Indent

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
      puts_indented(io, text)
      puts_indented(io)
    end

    def label(label : String, *, padding : Int = 0, & : self ->) : Nil
      puts_indented(io)
      print_indented(io, " " * padding, label, ' ')
      indent(label.size + 1) do
        yield self
      end
    end

    def value(value) : Nil
      print_indented(io, value)
    end

    def type(type) : Nil
      print_indented(io, type)
    end

    def code(code : String) : Nil
      puts_indented(io, code)
    end

    def with_style(style : Style, & : self ->) : Nil
      yield self
    end
  end
end
