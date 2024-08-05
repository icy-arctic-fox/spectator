module Spectator::Formatters
  module Indent
    DEFAULT_INDENT_AMOUNT = 2

    abstract def io : IO

    private property indent_amount = 0
    private property? newline = true

    def indent(amount : Int = DEFAULT_INDENT_AMOUNT, &) : Nil
      self.indent_amount += amount
      begin
        yield
      ensure
        self.indent_amount -= amount
      end
    end

    def <<(object) : self
      print_indent
      super
    end

    def puts(*objects) : Nil
      objects.each do |object|
        print_indent
        io.puts(object)
        @newline = true
      end
    end

    def puts : Nil
      io.puts
      self.newline = true
    end

    private def print_indent
      return unless newline?
      self.newline = false
      indent_amount.times { io << ' ' }
    end
  end
end
