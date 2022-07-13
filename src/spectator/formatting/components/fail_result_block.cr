require "colorize"
require "../../example"
require "../../expectation"
require "../../fail_result"
require "./result_block"

module Spectator::Formatting::Components
  # Displays information about a fail result.
  struct FailResultBlock < ResultBlock
    @longest_key : Int32

    # Creates the component.
    def initialize(example : Example, index : Int32, @expectation : Expectation, subindex = 0)
      super(example, index, subindex)
      @longest_key = expectation.values.max_of { |(key, _value)| key.to_s.size }
    end

    # Content displayed on the second line of the block after the label.
    private def subtitle
      @expectation.failure_message
    end

    # Prefix for the second line of the block.
    private def subtitle_label
      "Failure: ".colorize(:red)
    end

    # Display expectation match data.
    private def content(io)
      indent do
        @expectation.values.each do |(key, value)|
          value_line(io, key, value)
        end
      end

      io.puts
    end

    # Display a single line for a match data value.
    private def value_line(io, key, value)
      key = key.to_s
      padding = " " * (@longest_key - key.size)
      lines = value.lines

      line(io) do
        io << padding << key.colorize(:red) << ": ".colorize(:red) << lines.shift
      end

      unless lines.empty?
        indent(@longest_key + 2) do
          lines.each do |line|
            line(io) { io << line }
          end
        end
      end
    end

    # Produces the location line.
    # This is where the result was determined.
    private def location_line(io)
      return unless location = @expectation.location? || @example.location?

      line(io) { io << Comment.colorize(location) }
    end
  end
end
