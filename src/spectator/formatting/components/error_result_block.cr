require "colorize"
require "../../example"
require "../../error_result"
require "./result_block"

module Spectator::Formatting::Components
  struct ErrorResultBlock < ResultBlock
    def initialize(index : Int32, example : Example, @result : ErrorResult)
      super(index, example)
    end

    private def subtitle
      @result.error.message.try(&.each_line.first)
    end

    private def subtitle_label
      "Error: ".colorize(:red)
    end

    private def content(io)
      error = @result.error
      lines = error.message.try(&.lines) || {"<blank>".colorize(:purple)}

      line(io) do
        io << "#{error.class}: ".colorize(:red)
        io << lines.first
      end

      lines.skip(1).each do |entry|
        line(io) do
          io << entry
        end
      end

      error.backtrace?.try do |backtrace|
        indent { write_backtrace(io, backtrace) }
      end
    end

    private def write_backtrace(io, backtrace)
      backtrace.each do |entry|
        entry = entry.colorize.dim unless entry.starts_with?(/(src|spec)\//)
        line(io) { io << entry }
      end
    end
  end
end
