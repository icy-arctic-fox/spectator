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

    abstract def puts(*objects, style : Style) : Nil

    abstract def print(*objects, style : Style) : Nil

    abstract def print_value(& : IO ->) : Nil

    abstract def print_type(& : IO ->) : Nil

    abstract def print_title(style : Style = :none, & : IO ->) : Nil

    abstract def print_label(style : Style = :none, & : IO ->) : Nil

    abstract def print_inline_label(label : String, style : Style = :none, padding : Int = 0, &) : Nil

    abstract def print_code(code : String) : Nil
  end
end
