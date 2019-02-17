module Spectator::Formatters
  class FailureBlock
    def initialize(@index : Int32, @result : FailedResult)
    end

    def source(io)
      @result.example.source.to_s(io)
    end

    def to_s(io)
      to_s_title(io)
      to_s_message(io)
      to_s_expected_actual(io)
      to_s_source(io)
    end

    private def to_s_title(io)
      io << "  "
      io << @index
      io << ')'
      io << @result.example
      io.puts
    end

    private def to_s_message(io)
      io << "     Failure: "
      io << @result.error
      io.puts
    end

    private def to_s_expected_actual(io)
      io.puts
      io.puts "       Expected: TODO"
      io.puts "            got: TODO"
      io.puts
    end

    private def to_s_source(io)
      io << "     # "
      source(io)
    end
  end
end
