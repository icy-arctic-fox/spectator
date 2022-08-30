require "colorize"
require "../../example"
require "../../error_result"
require "./result_block"

module Spectator::Formatting::Components
  # Displays information about an error result.
  struct ErrorResultBlock < ResultBlock
    # Creates the component.
    def initialize(example : Example, index : Int32, @error : Exception, subindex = 0)
      super(example, index, subindex)
    end

    # Content displayed on the second line of the block after the label.
    private def subtitle
      @error.message.try(&.each_line.first)
    end

    # Prefix for the second line of the block.
    private def subtitle_label
      case @error
      when ExampleFailed then "Failure: "
      else                    "Error: "
      end.colorize(:red)
    end

    # Display error information.
    private def content(io)
      # Fetch the error and message.
      lines = @error.message.try(&.lines)

      # Write the error and message if available.
      case
      when lines.nil?      then write_error_class(io)
      when lines.size == 1 then write_error_message(io, lines.first)
      when lines.size > 1  then write_multiline_error_message(io, lines)
      else                      write_error_class(io)
      end

      # Display the backtrace if it's available.
      if backtrace = @error.backtrace?
        indent { write_backtrace(io, backtrace) }
      end

      io.puts
    end

    # Display just the error type.
    private def write_error_class(io)
      line(io) do
        io << @error.class.colorize(:red)
      end
    end

    # Display the error type and first line of the message.
    private def write_error_message(io, message)
      line(io) do
        io << "#{@error.class}: ".colorize(:red)
        io << message
      end
    end

    # Display the error type and its multi-line message.
    private def write_multiline_error_message(io, lines)
      # Use the normal formatting for the first line.
      write_error_message(io, lines.first)

      # Display additional lines after the first.
      lines.skip(1).each do |entry|
        line(io) { io << entry }
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
