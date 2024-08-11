module Spectator::Formatters
  module Indent
    DEFAULT_INDENT_AMOUNT = 2
    INDENT_STRING         = " "

    private property indent = ""
    private getter indent_size = 0
    private property? newline = true

    private def indent_size=(@indent_size : Int)
      self.indent = INDENT_STRING * indent_size
      indent_size
    end

    def indent(amount : Int = DEFAULT_INDENT_AMOUNT, & : self ->) : Nil
      self.indent_size += amount
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

    private def count_indent(text : String) : Int
      i = 0
      text.each_char do |char|
        return i unless char.whitespace?
        i += 1
      end
      -1 # Blank lines are not considered as indented.
    end

    private def reduce_indent(text : String) : String
      lines = text.lines(false)
      min_indent = lines.min_of do |line|
        size = count_indent(line)
        size < 0 ? Int32::MAX : size # Skip empty lines to avoid min being zero.
      end
      lines.map! { |line| line[min_indent..]? || "" }
      lines.join
    end
  end
end
