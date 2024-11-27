require "../assertion_failed"
require "../formatters/plain_printer"
require "../formatters/printer"

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

    def raise(location)
      raise AssertionFailed.new(self, location)
    end

    def print_failure_message(printer : Formatters::Printer) : Nil
      case failure_message = @failure_message
      in FailureMessagePrinter then failure_message.call(printer)
      in String                then printer << failure_message
      end
    end

    def to_s(io : IO) : Nil
      printer = Formatters::PlainPrinter.new(io)
      print_failure_message(printer)
    end
  end
end
