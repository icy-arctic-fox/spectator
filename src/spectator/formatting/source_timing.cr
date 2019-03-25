module Spectator::Formatting
  # Produces the timing line in a profile block.
  # This contains the length of time, and the example's source.
  private struct SourceTiming
    # Creates the source timing line.
    def initialize(@span : Time::Span, @source : Source)
    end

    # Appends the source timing information to the output.
    def to_s(io)
      io << HumanTime.new(@span).colorize.bold
      io << ' '
      io << @source
    end
  end
end
