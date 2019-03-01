module Spectator::Formatting
  # Produces a stringified command to run a failed test.
  private struct FailureCommand
    # Creates the failure command.
    def initialize(@example : Example)
    end

    # Appends the command to the output.
    def to_s(io)
      io << "crystal spec "
      io << @example.source
    end

    # Colorizes the command instance based on the result.
    def self.color(result)
      result.call(Color) { new(result.example) }
    end
  end
end
