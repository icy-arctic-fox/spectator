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
    # Creates the failure block.
    # The *index* uniquely identifies the failure in the output.
    # The *result* is the outcome of the failed example.
    def initialize(@index : Int32, @result : FailedResult)
    end

    # Creates the block of text describing the failure.
    def to_s(io)
      indent = Indent.new(io)
      inner_indent = integer_length(@index) + 2 # +2 for ) and space after number.

      indent.increase do
        title(indent)
        indent.increase(inner_indent) do
          message(indent)
          content(indent)
          source(indent)
        end
      end
    end

    # Produces the title of the failure block.
    # The line takes the form:
    # ```text
    # 1) Example name
    # ```
    private def title(indent)
      indent.line(NumberedItem.new(@index, @result.example))
    end

    # Produces the message line of the failure block.
    # The line takes the form:
    # ```text
    # Failure: Error message
    # ```
    # The indentation of this line starts directly under
    # the example name from the title line.
    private def message(indent)
      indent.line(FailureMessage.color(@result))
    end

    # Produces the main content of the failure block.
    # Any failed expectations are displayed,
    # then an error stacktrace if an error occurred.
    private def content(indent)
      indent.line
      indent.increase do
        unsatisfied_expectations(indent)
        error_stacktrace(indent) if @result.is_a?(ErroredResult)
      end
      indent.line
    end

    # Produces a list of unsatisfied expectations and their values.
    private def unsatisfied_expectations(indent)
      @result.expectations.each_unsatisfied do |expectation|
        # TODO: Failure message for this expectation.
        matcher_values(indent, expectation)
      end
    end

    # Produces the values list for an expectation
    private def matcher_values(indent, expectation)
      MatchDataValues.new(expectation.values).each do |pair|
        # TODO: Not all expectations will be failures (color green and red).
        indent.line(Color.failure(pair))
      end
    end

    # Produces the stack trace for an errored result.
    private def error_stacktrace(indent)
      error = @result.error
      loop do
        display_error(indent, error)
        if (next_error = error.cause)
          error = next_error
        else
          break
        end
      end
    end

    # Display a single error and its stacktrace.
    private def display_error(indent, error) : Nil
      indent.line(Color.error("Caused by: #{error.message} (#{error.class})"))
      indent.increase do
        error.backtrace.each do |frame|
          indent.line(Color.error(frame))
        end
      end
    end

    # Produces the source line of the failure block.
    private def source(indent)
      indent.line(Comment.color(@result.example.source))
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
