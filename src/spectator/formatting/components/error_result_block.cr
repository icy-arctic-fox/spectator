require "colorize"
require "../../example"
require "../../error_result"
require "./result_block"

module Spectator::Formatting::Components
  # Displays information about an error result.
  struct ErrorResultBlock < ResultBlock
    # Creates the component.
    def initialize(index : Int32, example : Example, @result : ErrorResult)
      super(index, example)
    end

    # Content displayed on the second line of the block after the label.
    private def subtitle
      @result.error.message.try(&.each_line.first)
    end

    # Prefix for the second line of the block.
    private def subtitle_label
      "Error: ".colorize(:red)
    end

    # Display error information.
    private def content(io)
      # Fetch the error and message.
      # If there's no message
      error = @result.error
      lines = error.message.try(&.lines) || {"<blank>".colorize(:purple)}

      # Display the error type and first line of the message.
      line(io) do
        io << "#{error.class}: ".colorize(:red)
        io << lines.first
      end

      # Display additional lines after the first if there's any.
      lines.skip(1).each do |entry|
        line(io) { io << entry }
      end

      # Display the backtrace if it's available.
      if backtrace = error.backtrace?
        indent { write_backtrace(io, backtrace) }
      end
    end

    # Writes the backtrace entries to the output.
    private def write_backtrace(io, backtrace)
      backtrace.each do |entry|
        # Dim entries that are outside the shard.
        entry = entry.colorize.dim unless entry.starts_with?(/(src|spec)\//)
        line(io) { io << entry }
      end
    end
  end
end
