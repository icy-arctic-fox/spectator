require "colorize"

module Spectator::Formatting::Components
  # Displays counts for each type of example result (pass, fail, error, pending).
  struct Totals
    # Creates the component with the specified counts.
    def initialize(@examples : Int32, @failures : Int32, @errors : Int32, @pending : Int32)
    end

    # Creates the component by pulling numbers from *counts*.
    def initialize(counts)
      @examples = counts.run
      @failures = counts.fail
      @errors = counts.error
      @pending = counts.pending
    end

    # Creates the component, but colors it whether there were pending or failed results.
    # The component will be red if there were failures (or errors),
    # yellow if there were pending/skipped tests,
    # and green if everything passed.
    def self.colorize(counts)
      totals = new(counts)
      if counts.fail > 0
        totals.colorize(:red)
      elsif counts.pending > 0
        totals.colorize(:yellow)
      else
        totals.colorize(:green)
      end
    end

    # Writes the counts to the output.
    def to_s(io : IO) : Nil
      io << @examples << " examples, " << @failures << " failures"

      if @errors > 0
        io << " (" << @errors << " errors)"
      end

      if @pending > 0
        io << ", " << @pending << " pending"
      end
    end
  end
end
