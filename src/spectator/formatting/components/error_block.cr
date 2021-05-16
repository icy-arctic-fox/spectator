require "../../example"
require "../../error_result"
require "./comment"

module Spectator::Formatting::Components
  struct ErrorBlock
    private INDENT = 2

    def initialize(@example : Example, @result : ErrorResult, @index : Int32)
    end

    def to_s(io)
      2.times { io << ' ' }
      io << @index
      io << ')'
      io << ' '
      io.puts @example
      indent = INDENT + index_digit_count + 2
      indent.times { io << ' ' }
      error = @result.error
      io << "Error: ".colorize(:red)
      io.puts error.message
      io.puts
      indent.times { io << ' ' }
      io << error.class
      io.puts ':'
      indent += INDENT
      error.backtrace?.try do |trace|
        trace.each do |entry|
          indent.times { io << ' ' }
          entry = entry.colorize.dim unless entry.starts_with?(/src\/|spec\//)
          io.puts entry
        end
      end
      indent -= INDENT
      indent.times { io << ' ' }
      io.puts Comment.colorize(@example.location) # TODO: Use location of failed expectation.
    end

    private def index_digit_count
      (Math.log(@index.to_f + 1) / Math.log(10)).ceil.to_i
    end
  end
end
