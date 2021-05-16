require "./example_command"

module Spectator::Formatting::Components
  struct FailureCommandList
    def initialize(@failures : Enumerable(Example))
    end

    def to_s(io)
      io.puts "Failed examples:"
      io.puts
      @failures.each do |failure|
        io.puts ExampleCommand.new(failure).colorize(:red)
      end
    end
  end
end
