module Spectator::Formatting
  # Tracks indentation for text output.
  # To use, create an instance and call `#increase` when a block should be indented.
  # The `#increase` method yields, so additional `#increase` and `#line` methods can be called.
  # Then call `#line` to produce a line of text at the current indent.
  # ```
  # indent = Indent.new(io)
  # indent.increase do
  #   indent.line("Text")
  #   indent.increase do
  #     indent.line("More text")
  #   end
  # end
  # ```
  private struct Indent
    # Default number of spaces to indent by.
    INDENT_SIZE = 2

    # Creates the identation tracker.
    # The *io* is the stream to output to.
    # The *indent_size* is how much (number of spaces) to indent at each level.
    # The *initial_indent* is what the ident should be set to.
    def initialize(@io : IO, @indent_size = INDENT_SIZE, inital_indent @indent = 0)
    end

    # Indents the text and yields.
    def increase(&block)
      increase(@indent_size, &block)
    end

    # Indents the text by a specified amount and yields.
    def increase(amount) : Nil
      @indent += amount
      yield
    ensure
      @indent -= amount
    end

    # Produces an empty line.
    def line
      @io.puts
    end

    # Produces a line of indented text.
    def line(text)
      @indent.times { @io << ' ' }
      @io.puts text
    end
  end
end
