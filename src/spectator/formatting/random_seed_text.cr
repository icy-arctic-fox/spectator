module Spectator::Formatting
  # Text displayed when using a random seed.
  private struct RandomSeedText
    # Creates the text object.
    def initialize(@seed : UInt64)
    end

    # Appends the command to the output.
    def to_s(io)
      io << "Randomized with seed "
      io << @seed
    end
  end
end
