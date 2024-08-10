module Spectator::Formatters
  module Indent
    DEFAULT_INDENT_AMOUNT = 2
    INDENT_STRING         = " "

    private property indent = ""
    private property indent_size = 0
    private property? newline = true

    def indent(amount : Int = DEFAULT_INDENT_AMOUNT, & : self ->) : Nil
      self.indent_size += amount
      self.indent = INDENT_STRING * indent_size
      begin
        yield self
      ensure
        self.indent_size -= amount
      end
    end

    private def print_indented(io : IO, *objects) : Nil
      objects.each do |object|
        maybe_print_indent(io)
        string = insert_indent(object.to_s)
        io.print string
      end
    end

    private def puts_indented(io : IO, *objects) : Nil
      if objects.empty?
        io.puts
        self.newline = true
        return
      end

      objects.each do |object|
        maybe_print_indent(io)
        string = object.to_s.chomp
        string = insert_indent(string)
        io.puts string
        self.newline = true
      end
    end

    private def maybe_print_indent(io : IO) : Nil
      return unless newline?
      io << indent
      self.newline = false
    end

    private def insert_indent(text : String) : String
      return text unless text.includes?('\n')
      text.gsub('\n', "\n#{indent}")
    end
  end
end
