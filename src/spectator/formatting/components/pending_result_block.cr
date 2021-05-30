require "colorize"
require "../../example"
require "../../pending_result"
require "./result_block"

module Spectator::Formatting::Components
  # Displays information about a pending result.
  struct PendingResultBlock < ResultBlock
    # Creates the component.
    def initialize(index : Int32, example : Example, @result : PendingResult)
      super(index, example)
    end

    # Content displayed on the second line of the block after the label.
    private def subtitle
      "No reason given" # TODO: Get reason from result.
    end

    # Prefix for the second line of the block.
    private def subtitle_label
      # TODO: Could be pending or skipped.
      "Pending: ".colorize(:yellow)
    end

    # No content for this type of block.
    private def content(io)
    end
  end
end
