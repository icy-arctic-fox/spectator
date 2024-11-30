require "./indent"
require "./printer"

module Spectator::Formatters
  class PlainPrinter < Printer
    include Indent

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
      puts_indented(io) unless newline?
      print_indented(io, " " * padding, label, ' ')
      indent(label.size + 1) do
        yield self
      end
    end

    def value(value) : Nil
      print_indented(io, value.inspect)
    end

    def inspect_value(value) : Nil
      string = value.pretty_inspect
      string = if value.is_a?(Reference)
                 "#{string} (object_id: #{value.object_id})"
               else
                 "#{string} : #{value.class}"
               end
      print_indented(io, string)
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
