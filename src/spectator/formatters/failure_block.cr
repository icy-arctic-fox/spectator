module Spectator::Formatters
  # Constructs a block of text containing information about a failed example.
  #
  # A failure block takes the form:
  #
  # ```text
  #   1) Example name
  #      Failure: Reason or message
  #
  #      Expected: value
  #           got: value
  #
  #  # spec/source_spec.cr:42
  # ```
  class FailureBlock
    # Number of spaces to indent the block by.
    INITIAL_INDENT = 2

    # Number of spaces to add for each level of indentation.
    INTENT_SIZE = 2

    @index_length : Int32

    # Creates the failure block.
    # The *index* uniquely identifies the failure in the output.
    # The *result* is the outcome of the failed example.
    def initialize(@index : Int32, @result : FailedResult)
      @index_length = integer_length(@index)
    end

    # Creates the block of text describing the failure.
    def to_s(io)
      title(io)
      message(io)
      values(io)
      source(io)
    end

    # Produces the title of the failure block.
    # The line takes the form:
    # ```text
    #   1) Example name
    # ```
    private def title(io)
      INITIAL_INDENT.times { io << ' ' }
      io << @index
      io << ')'
      io << ' '
      io << @result.example
      io.puts
    end

    # Produces the message line of the failure block.
    # The line takes the form:
    # ```text
    #      Failure: Error message
    # ```
    # The indentation of this line starts directly under
    # the example name from the title line.
    private def message(io)
      INITIAL_INDENT.times { io << ' ' }
      (@index_length + 2).times { io << ' ' } # +2 for ) and space.
      io << Color.failure("Failure: ")
      io << Color.failure(@result.error)
      io.puts
    end

    # Produces the values list of the failure block.
    private def values(io)
      io.puts
      io.puts "       Expected: TODO"
      io.puts "            got: TODO"
      io.puts
    end

    # Produces the source line of the failure block.
    private def source(io)
      INITIAL_INDENT.times { io << ' ' }
      (@index_length + 2).times { io << ' ' } # +2 for ) and space.
      io << Comment.color(@result.example.source)
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
