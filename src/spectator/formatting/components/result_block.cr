require "../../example"
require "./block"
require "./comment"

module Spectator::Formatting::Components
  # Base class that displayed indexed results in block form.
  # These typically take the form:
  # ```text
  # 1) Title
  #    Label: Subtitle
  #
  #    Content
  #    # Source
  # ```
  abstract struct ResultBlock < Block
    # Creates the block with the specified *index* and for the given *example*.
    def initialize(@example : Example, @index : Int32, @subindex : Int32 = 0)
      super()
    end

    # Content displayed on the first line of the block.
    # Will be stringified.
    # By default, uses the example name.
    # Can be overridden to use a different value.
    private def title
      @example
    end

    # Content displayed on the second line of the block after the label.
    # Will be stringified.
    private abstract def subtitle

    # Prefix for the second line of the block.
    # Will be stringified.
    # This is typically something like "Error:" or "Failure:"
    private abstract def subtitle_label

    # Produces the main content of the block.
    # *io* is the stream to write to.
    # `#line` and `#indent` (from `Block`) should be used to maintain spacing.
    private abstract def content(io)

    # Writes the component's output to the specified stream.
    def to_s(io : IO) : Nil
      title_line(io)
      # Ident over to align with the spacing used by the index.
      indent(index_digit_count + 2) do
        subtitle_line(io)
        io.puts
        content(io)
        location_line(io)
      end
    end

    # Produces the title line.
    private def title_line(io)
      line(io) do
        io << @index
        io << '.' << @subindex if @subindex > 0
        io << ") " << title
      end
    end

    # Produces the subtitle line.
    private def subtitle_line(io)
      line(io) do
        io << subtitle_label << subtitle
      end
    end

    # Produces the location line.
    # This is where the result was determined.
    private def location_line(io)
      location = if (result = @example.result).responds_to?(:location?)
                   result.location?
                 end
      location ||= @example.location?
      return unless location

      line(io) { io << Comment.colorize(location) }
    end

    # Computes the number of spaces the index takes
    private def index_digit_count
      count = digit_count(@index)
      count += 1 + digit_count(@subindex) if @subindex > 0
      count
    end

    # Computes the number of spaces an integer takes.
    private def digit_count(integer)
      (Math.log(integer.to_f + 1) / Math::LOG10).ceil.to_i
    end
  end
end
