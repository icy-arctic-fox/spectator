module Spectator::Formatting::Components
  struct ExampleFilterCommand
    def initialize(@example : Example)
    end

    def to_s(io)
      io << "crystal spec "
      io << @example.location
      io << ' '
      io << Comment.colorize(@example.to_s)
    end
  end
end
