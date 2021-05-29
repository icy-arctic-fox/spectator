require "colorize"
require "../../example"
require "../../fail_result"
require "./result_block"

module Spectator::Formatting::Components
  struct FailResultBlock < ResultBlock
    def initialize(index : Int32, example : Example, @result : FailResult)
      super(index, example)
    end

    private def subtitle
      @result.error.message.try(&.each_line.first)
    end

    private def subtitle_label
      "Failure: ".colorize(:red)
    end

    private def content(io)
      # TODO: Display match data.
    end
  end
end
