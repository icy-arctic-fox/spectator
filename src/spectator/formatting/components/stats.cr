require "./example_command"
require "./runtime"
require "./totals"

module Spectator::Formatting::Components
  # Statistics information displayed at the end of a run.
  struct Stats
    def initialize(@report : Report)
    end

    def to_s(io)
      timing_line(io)
      totals_line(io)

      unless (failures = @report.failures).empty?
        io.puts
        failures_block(io, failures)
      end
    end

    private def timing_line(io)
      io << "Finished in "
      io.puts Runtime.new(@report.runtime)
    end

    private def totals_line(io)
      io.puts Totals.colorize(@report.counts)
    end

    private def failures_block(io, failures)
      io.puts "Failed examples:"
      io.puts
      failures.each do |failure|
        io.puts ExampleCommand.new(failure).colorize(:red)
      end
    end
  end
end
