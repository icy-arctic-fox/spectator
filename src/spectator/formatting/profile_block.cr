module Spectator::Formatting
  # Contents of a profile block.
  private struct ProfileBlock
    # Creates the block.
    def initialize(@profile : Profile)
    end

    # Appends the block to the output.
    def to_s(io)
      io.puts(ProfileSummary.new(@profile))

      indent = Indent.new(io)
      indent.increase do
        @profile.each do |result|
          entry(indent, result)
        end
      end
    end

    # Adds a result entry to the output.
    private def entry(indent, result)
      indent.line(result.example)
      indent.increase do
        indent.line(SourceTiming.new(result.elapsed, result.example.source))
      end
    end
  end
end
