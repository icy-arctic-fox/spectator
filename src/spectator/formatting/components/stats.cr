require "colorize"
require "../../report"
require "./runtime"
require "./totals"

module Spectator::Formatting::Components
  # Statistics information displayed at the end of a run.
  struct Stats
    # Creates the component with stats from *report*.
    def initialize(@report : Report)
    end

    # Displays the stats.
    def to_s(io : IO) : Nil
      runtime(io)
      totals(io)
      if seed = @report.random_seed?
        random(io, seed)
      end
    end

    # Displays the time it took to run the suite.
    private def runtime(io)
      io << "Finished in "
      io.puts Runtime.new(@report.runtime)
    end

    # Displays the counts for each type of result.
    private def totals(io)
      io.puts Totals.colorize(@report.counts)
    end

    # Displays the random seed.
    private def random(io, seed)
      io.puts "Randomized with seed: #{seed}".colorize(:cyan)
    end
  end
end
