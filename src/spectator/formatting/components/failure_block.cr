require "../../example"
require "./comment"

module Spectator::Formatting::Components
  struct FailureBlock
    private INDENT = 2

    def initialize(@example : Example, @index : Int32)
      @result = @example.result.as(FailResult)
    end

    def to_s(io)
      2.times { io << ' ' }
      io << @index
      io << ')'
      io << ' '
      io.puts @example
      indent = INDENT + index_digit_count + 2
      indent.times { io << ' ' }
      io << "Failure: ".colorize(:red)
      io.puts @result.error.message
      io.puts
      # TODO: Expectation values
      indent.times { io << ' ' }
      io.puts Comment.colorize(@example.location) # TODO: Use location of failed expectation.
    end

    private def index_digit_count
      (Math.log(@index.to_f + 1) / Math.log(10)).ceil.to_i
    end
  end
end
