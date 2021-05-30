require "colorize"
require "../../example"
require "../../fail_result"
require "./result_block"

module Spectator::Formatting::Components
  # Displays information about a fail result.
  struct FailResultBlock < ResultBlock
    # Creates the component.
    def initialize(index : Int32, example : Example, @result : FailResult)
      super(index, example)
    end

    # Content displayed on the second line of the block after the label.
    private def subtitle
      @result.error.message.try(&.each_line.first)
    end

    # Prefix for the second line of the block.
    private def subtitle_label
      "Failure: ".colorize(:red)
    end

    # Display expectation match data.
    private def content(io)
      # TODO: Display match data.
    end
  end
end
