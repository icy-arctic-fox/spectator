require "../../profile"
require "./runtime"

module Spectator::Formatting::Components
  struct TAPProfile
    def initialize(@profile : Spectator::Profile)
    end

    def to_s(io)
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

    private def example_profile(io, example)
      io << "#   "
      io.puts example
      io << "#     "
      io << Runtime.new(example.result.elapsed)
      io << ' '
      io.puts example.location
    end
  end
end
