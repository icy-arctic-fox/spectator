require "./comment"

module Spectator::Formatting::Components
  struct ExampleCommand
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
