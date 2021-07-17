require "../../example"
require "../../location"
require "./comment"

module Spectator::Formatting::Components
  # Provides syntax for running a specific example from the command-line.
  struct ExampleCommand
    # Creates the component with the specified example.
    # The location can be overridden, for instance, pointing to a problematic line in the example.
    # Otherwise the example's location is used.
    def initialize(@example : Example, @location : Location? = nil)
    end

    # Produces output for running the previously specified example.
    def to_s(io)
      io << "crystal spec "

      # Use location for argument if it's available, since it's simpler.
      # Otherwise, use the example name filter argument.
      if location = (@location || @example.location?)
        io << location
      else
        io << "-e " << @example
      end

      io << ' ' << Comment.colorize(@example.to_s)
    end
  end
end
