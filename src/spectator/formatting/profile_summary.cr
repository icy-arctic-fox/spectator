module Spectator::Formatting
  # Top line of a profile block which gives a summary.
  private struct ProfileSummary
    # Creates the summary line.
    def initialize(@profile : Profile)
    end

    # Appends the summary to the output.
    def to_s(io)
      io << "Top "
      io << @profile.size
      io << " slowest examples ("
      io << human_time
      io << ", "
      io.printf("%.2f", percentage)
      io << "% of total time):"
    end

    # Creates a human-friendly string for the total time.
    private def human_time
      HumanTime.new(@profile.total_time)
    end

    # Percentage (0 to 100) of total time.
    private def percentage
      @profile.percentage * 100
    end
  end
end
