module Spectator::Formatting
  # Constructs a block of text containing information about a failed example.
  #
  # A failure block takes the form:
  #
  # ```text
  #   1) Example name
  #      Failure: Reason or message
  #
  #        Expected: value
  #             got: value
  #
  #      # spec/source_spec.cr:42
  # ```
  private struct FailureBlock
    # Default number of spaces to add for each level of indentation.
    INDENT_SIZE = 2

    # Creates the failure block.
    # The *index* uniquely identifies the failure in the output.
    # The *result* is the outcome of the failed example.
    def initialize(@index : Int32, @result : FailedResult)
      @indent = 0
    end

    # Creates the block of text describing the failure.
    def to_s(io)
      inner_indent = integer_length(@index) + 2 # +2 for ) and space after number.

      indent do
        title(io)
        indent(inner_indent) do
          message(io)
          content(io)
          source(io)
        end
      end
    end

    # Produces the title of the failure block.
    # The line takes the form:
    # ```text
    # 1) Example name
    # ```
    private def title(io)
      line(io, NumberedItem.new(@index, @result.example))
    end

    # Produces the message line of the failure block.
    # The line takes the form:
    # ```text
    # Failure: Error message
    # ```
    # The indentation of this line starts directly under
    # the example name from the title line.
    private def message(io)
      line(io, FailureMessage.color(@result))
    end

    # Produces the main content of the failure block.
    private def content(io)
      io.puts
      if(@result.is_a?(ErroredResult))
        stack_trace(io)
      else
        values(io)
      end
      io.puts
    end

    # Produces the values list of the failure block.
    private def values(io)
      indent do
        @result.expectations.each_unsatisfied do |expectation|
          MatchDataValues.new(expectation.values).each do |pair|
            line(io, Color.failure(pair))
          end
        end
      end
    end

    # Produces the stack trace for an errored result.
    private def stack_trace(io)
      error = @result.error
      indent do
        loop do
          display_error(io, error)
          if (next_error = error.cause)
            error = next_error
          else
            break
          end
        end
      end
    end

    # Display a single error and its stacktrace.
    private def display_error(io, error) : Nil
      line(io, Color.error("Caused by: #{error.message} (#{error.class})"))
      indent do
        error.backtrace.each do |frame|
          line(io, Color.error(frame))
        end
      end
    end

    # Produces the source line of the failure block.
    private def source(io)
      line(io, Comment.color(@result.example.source))
    end

    # Increases the indentation for a block of text.
    private def indent(amount = INDENT_SIZE)
      @indent += amount
      yield
    ensure
      @indent -= amount
    end

    # Produces a line of text with a leading indent.
    private def line(io, text)
      @indent.times { io << ' ' }
      io.puts text
    end

    # Gets the number of characters a positive integer spans in base 10.
    private def integer_length(index)
      count = 1
      while index >= 10
        index /= 10
        count += 1
      end
      count
    end
  end
end