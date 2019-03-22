module Spectator::Formatting
  # Produces a stringified stats counter from result totals.
  private struct StatsCounter
    # Creates the instance with each of the counters.
    private def initialize(@examples : Int32, @failures : Int32, @errors : Int32, @pending : Int32, @failed : Bool)
    end

    # Creates the instance from the counters in a report.
    def initialize(report)
      initialize(report.example_count, report.failed_count, report.error_count, report.pending_count, report.failed?)
    end

    # Produces a colorized formatting for the stats,
    # depending on the number of each type of result.
    def color
      if @errors > 0
        Color.error(self)
      elsif @failed || @failures > 0
        Color.failure(self)
      elsif @pending > 0
        Color.pending(self)
      else
        Color.success(self)
      end
    end

    # Appends the counters to the output.
    # The format will be:
    # ```text
    # # examples, # failures, # errors, # pending
    # ```
    def to_s(io)
      stats.each_with_index do |stat, value, index|
        io << ", " if index > 0
        io << value
        io << ' '
        io << stat
      end
    end

    private def stats
      {
        examples: @examples,
        failures: @failures,
        errors:   @errors,
        pending:  @pending,
      }
    end
  end
end
