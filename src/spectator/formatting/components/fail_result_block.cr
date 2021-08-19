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

      line(io) do
        io << padding << key.colorize(:red) << ": ".colorize(:red) << value
      end
    end
  end
end
