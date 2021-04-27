module Spectator::Formatting
  # Produces a formatted TAP test line.
  private struct TAPTestLine
    # Creates the test line.
    def initialize(@index : Int32, @example : Example)
    end

    # Appends the line to the output.
    def to_s(io)
      io << status
      io << ' '
      io << @index
      io << " - "
      io << @example
      io << " # skip" if pending?
    end

    # The text "ok" or "not ok" depending on the result.
    private def status
      result.is_a?(FailResult) ? "not ok" : "ok"
    end

    # The result of running the example.
    private def result
      @example.result
    end

    # Indicates whether this test was skipped.
    private def pending?
      result.is_a?(PendingResult)
    end
  end
end
