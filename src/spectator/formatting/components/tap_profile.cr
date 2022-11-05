require "../../profile"
require "./runtime"

module Spectator::Formatting::Components
  # Displays profiling information for slow examples in a TAP format.
  # Produces output similar to `Profile`, but formatted for TAP.
  struct TAPProfile
    # Creates the component with the specified *profile*.
    def initialize(@profile : Spectator::Profile)
    end

    # Produces the output containing the profiling information.
    def to_s(io : IO) : Nil
      io << "# Top "
      io << @profile.size
      io << " slowest examples ("
      io << Runtime.new(@profile.time)
      io << ", "
      io << @profile.percentage.round(2)
      io.puts "% of total time):"

      @profile.each do |example|
        example_profile(io, example)
      end
    end

    # Writes a single example's timing to the output.
    private def example_profile(io, example)
      io << "#   "
      io.puts example
      io << "#     "
      io << Runtime.new(example.result.elapsed)

      if location = example.location?
        io << ' '
        io.puts location
      else
        io.puts
      end
    end
  end
end
