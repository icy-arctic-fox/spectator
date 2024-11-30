require "../assertion_failed"
require "../formatters"

module Spectator::Matchers
  alias FailureMessagePrinter = Formatters::Printer ->

  struct MatchFailure
    @failure_message : String | FailureMessagePrinter

    def initialize(failure_message : String)
      @failure_message = failure_message
    end

    def initialize(&block : FailureMessagePrinter)
      @failure_message = block
    end

    def raise(location : Core::LocationRange? = nil)
      raise AssertionFailed.new(self, location)
    end

    def format(printer : Formatters::Printer) : Nil
      case failure_message = @failure_message
      in FailureMessagePrinter then failure_message.call(printer)
      in String                then printer << failure_message
      end
    end

    def to_s(io : IO) : Nil
      Formatters.to_io(io) do |printer|
        format(printer)
      end
    end
  end
end
