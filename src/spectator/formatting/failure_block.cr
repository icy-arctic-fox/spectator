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
    # Any failed expectations are displayed,
    # then an error stacktrace if an error occurred.
    private def content(io)
      io.puts
      indent do
        unsatisfied_expectations(io)
        error_stacktrace(io) if @result.is_a?(ErroredResult)
      end
      io.puts
    end

    # Produces a list of unsatisfied expectations and their values.
    private def unsatisfied_expectations(io)
      @result.expectations.each_unsatisfied do |expectation|
        # TODO: Failure message for this expectation.
        matcher_values(io, expectation)
      end
    end

    # Produces the values list for an expectation
    private def matcher_values(io, expectation)
      MatchDataValues.new(expectation.values).each do |pair|
        # TODO: Not all expectations will be failures (color green and red).
        line(io, Color.failure(pair))
      end
    end

    # Produces the stack trace for an errored result.
    private def error_stacktrace(io)
      error = @result.error
      loop do
        display_error(io, error)
        if (next_error = error.cause)
          error = next_error
        else
          break
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
