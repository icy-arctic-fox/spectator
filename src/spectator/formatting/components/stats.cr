require "./runtime"
require "./totals"

module Spectator::Formatting::Components
  # Statistics information displayed at the end of a run.
  struct Stats
    def initialize(@report : Report)
    end

    def to_s(io)
      runtime(io)
      totals(io)
    end

    private def runtime(io)
      io << "Finished in "
      io.puts Runtime.new(@report.runtime)
    end

    private def totals(io)
      io.puts Totals.colorize(@report.counts)
    end
  end
end
