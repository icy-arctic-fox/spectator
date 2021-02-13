module Spectator::Formatting
  # Produces the timing line in a profile block.
  # This contains the length of time, and the example's location.
  private struct LocationTiming
    # Creates the location timing line.
    def initialize(@span : Time::Span, @location : Location)
    end

    # Appends the location timing information to the output.
    def to_s(io)
      io << HumanTime.new(@span).colorize.bold
      io << ' '
      io << @location
    end
  end
end
