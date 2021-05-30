require "../../example"
require "./comment"

module Spectator::Formatting::Components
  # Provides syntax for running a specific example from the command-line.
  struct ExampleCommand
    # Creates the component with the specified example.
    def initialize(@example : Example)
    end

    # Produces output for running the previously specified example.
    def to_s(io)
      io << "crystal spec "
      io << @example.location
      io << ' '
      io << Comment.colorize(@example.to_s)
    end
  end
end
