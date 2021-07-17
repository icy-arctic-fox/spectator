require "../../example"
require "./example_command"

module Spectator::Formatting::Components
  # Produces a list of commands to run failed examples.
  struct FailureCommandList
    # Creates the component.
    # Requires a set of *failures* to display commands for.
    def initialize(@failures : Enumerable(Example))
    end

    # Produces the list of commands to run failed examples.
    def to_s(io)
      io.puts "Failed examples:"
      io.puts
      @failures.each do |failure|
        # Use failed location if it's available.
        if (result = failure.result).responds_to?(:location)
          location = result.location
        end

        io.puts ExampleCommand.new(failure, location).colorize(:red)
      end
    end
  end
end
