module Spectator::Formatters
  enum Style
    None
    Info
    Success
    Warning
    Error
  end

  abstract class Printer
    private getter io : IO

    def initialize(@io = STDOUT)
    end

    def <<(object) : self
      print(object)
      self
    end

    abstract def print(*objects) : Nil

    abstract def puts(*objects) : Nil

    abstract def title(text : String) : Nil

    def label(label : String, text : String, *, padding : Int = 0) : Nil
      label(label, padding: padding) do |printer|
        printer << text
      end
    end

    abstract def label(label : String, *, padding : Int = 0, & : self ->) : Nil

    abstract def value(value) : Nil

    abstract def type(type) : Nil

    abstract def code(code : String) : Nil

    abstract def with_style(style : Style, & : self ->) : Nil
  end
end
