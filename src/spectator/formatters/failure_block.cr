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
    # Creates the failure block.
    # The `index` uniquely identifies the failure in the output.
    # The `result` is the outcome of the failed example.
    def initialize(@index : Int32, @result : FailedResult)
    end

    # Creates the block of text describing the failure.
    def to_s(io)
      title(io)
      message(io)
      values(io)
      source(io)
    end

    # Produces the title of the failure block.
    private def title(io)
      io << "  "
      io << @index
      io << ')'
      io << @result.example
      io.puts
    end

    # Produces the message line of the failure block.
    private def message(io)
      io << "     Failure: "
      io << @result.error
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
      io << "     # "
      @result.example.source.to_s(io)
    end
  end
end
