require "../../example"
require "./comment"

module Spectator::Formatting::Components
  struct PendingBlock
    private INDENT = 2

    def initialize(@example : Example, @index : Int32)
    end

    def to_s(io)
      2.times { io << ' ' }
      io << @index
      io << ')'
      io << ' '
      io.puts @example
      indent = INDENT + index_digit_count + 2
      indent.times { io << ' ' }
      io.puts Comment.colorize("No reason given") # TODO: Get reason from result.
      indent.times { io << ' ' }
      io.puts Comment.colorize(@example.location) # TODO: Pending result could be triggered from another location.
    end

    private def index_digit_count
      (Math.log(@index.to_f + 1) / Math.log(10)).ceil.to_i
    end
  end
end
