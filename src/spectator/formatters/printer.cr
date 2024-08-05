module Spectator::Formatters
  enum Style
    None
    Info
    Warning
    Error
  end

  abstract class Printer
    private getter io : IO

    def initialize(@io = STDOUT)
    end

    def <<(object) : self
      io << object
      self
    end

    def puts(*objects) : Nil
      io.puts(*objects)
    end

    abstract def print_value(& : IO ->) : Nil

    abstract def print_type(& : IO ->) : Nil

    abstract def print_title(style : Style = :none, & : IO ->) : Nil

    abstract def print_label(style : Style = :none, & : IO ->) : Nil

    abstract def print_inline_label(label : String, style : Style = :none, padding : Int = 0, &) : Nil

    abstract def print_code(code : String) : Nil
  end
end
