module Spectator::Formatting::Components
  abstract struct Block
    private INDENT = 2

    def initialize(*, @indent : Int32 = INDENT)
    end

    private def indent(amount = INDENT)
      @indent += amount
      yield
      @indent -= amount
    end

    private def line(io)
      @indent.times { io << ' ' }
      yield
      io.puts
    end
  end
end
