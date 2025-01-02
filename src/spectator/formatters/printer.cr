module Spectator::Formatters
  enum Style
    None
    Info
    Success
    Warning
    Error
  end

  enum StringProperty
    ObjectId
    Size
    Bytesize
  end

  module Printable
    abstract def print(printer : Printer) : Nil

    def to_s(io : IO) : Nil
      Formatters.to_io(io) do |printer|
        print(printer)
      end
    end
  end

  abstract class Printer
    private getter io : IO

    def initialize(@io = STDOUT)
    end

    def <<(object) : self
      print(object)
      self
    end

    def <<(object : Printable) : self
      object.print(self)
      self
    end

    abstract def print(*objects) : Nil

    def print(*objects : Printable) : Nil
      objects.each &.print(self)
    end

    abstract def puts(*objects) : Nil

    def puts(*objects : Printable) : Nil
      objects.each &.print(self)
      puts if objects.empty?
    end

    abstract def title(text : String) : Nil

    def label(label : String, text : String, *, padding : Int = 0) : Nil
      label(label, padding: padding) do |printer|
        printer << text
      end
    end

    abstract def label(label : String, *, padding : Int = 0, & : self ->) : Nil

    abstract def value(value) : Nil

    abstract def id(value) : Nil

    abstract def inspect_value(value) : Nil

    abstract def inspect_string(value : String, property : StringProperty = :object_id) : Nil

    abstract def type(type) : Nil

    abstract def code(code : String) : Nil

    abstract def with_style(style : Style, & : self ->) : Nil
  end
end
