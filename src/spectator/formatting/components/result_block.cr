require "../../example"
require "./block"
require "./comment"

module Spectator::Formatting::Components
  abstract struct ResultBlock < Block
    def initialize(@index : Int32, @example : Example)
      super()
    end

    private def title
      @example
    end

    private abstract def subtitle

    private abstract def subtitle_label

    def to_s(io)
      title_line(io)
      indent(index_digit_count + 2) do
        subtitle_line(io)
        io.puts
        content(io)
        source_line(io)
      end
    end

    private def title_line(io)
      line(io) do
        io << @index
        io << ')'
        io << ' '
        io << title
      end
    end

    private def subtitle_line(io)
      line(io) do
        io << subtitle_label
        io << subtitle
      end
    end

    private def source_line(io)
      source = if (result = @example.result).responds_to?(:source)
        result.source
      else
        @example.location
      end
      line(io) { io << Comment.colorize(source) }
    end

    private def index_digit_count
      (Math.log(@index.to_f + 1) / Math::LOG10).ceil.to_i
    end
  end
end
