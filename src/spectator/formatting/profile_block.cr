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
        @profile.each do |example|
          entry(indent, example)
        end
      end
    end

    # Adds a result entry to the output.
    private def entry(indent, example)
      indent.line(example)
      indent.increase do
        indent.line(LocationTiming.new(example.result.elapsed, example.location))
      end
    end
  end
end
