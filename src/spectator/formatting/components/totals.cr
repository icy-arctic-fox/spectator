module Spectator::Formatting::Components
  struct Totals
    def initialize(@examples : Int32, @failures : Int32, @errors : Int32, @pending : Int32)
    end

    def initialize(counts)
      @examples = counts.run
      @failures = counts.fail
      @errors = counts.error
      @pending = counts.pending
    end

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

    def to_s(io)
      io << @examples
      io << " examples, "
      io << @failures
      io << " failures, "
      io << @errors
      io << " errors, "
      io << @pending
      io << " pending"
    end
  end
end
