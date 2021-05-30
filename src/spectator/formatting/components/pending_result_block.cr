require "../../example"
require "../../pending_result"
require "./result_block"

module Spectator::Formatting::Components
  struct PendingResultBlock < ResultBlock
    def initialize(index : Int32, example : Example, @result : PendingResult)
      super(index, example)
    end

    private def subtitle
      "No reason given" # TODO: Get reason from result.
    end

    private def subtitle_label
      # TODO: Could be pending or skipped.
      "Pending: ".colorize(:yellow)
    end

    private def content(io)
    end
  end
end
