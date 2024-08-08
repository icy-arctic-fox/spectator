require "../core/location_range"
require "../formatters/plain_printer"
require "./formatting"

module Spectator::Matchers
  abstract struct MatchData
    getter location : Core::LocationRange?

    def initialize(@location : Core::LocationRange? = nil)
    end

    abstract def passed? : Bool

    def failed? : Bool
      !passing?
    end

    abstract def try_raise : Nil

    abstract def format(printer : Formatters::Printer) : Nil
  end

  struct PassedMatchData < MatchData
    def passed? : Bool
      true
    end

    def to_s(io : IO) : Nil
      io << "Passed"
    end

    def try_raise : Nil
      # ...
    end

    def format(printer : Formatters::Printer) : Nil
      printer << "Passed"
    end
  end

  struct FailedMatchData < MatchData
    getter message : String do
      to_s
    end

    @proc : (FormattingPrinter ->)?

    def initialize(@message : String, location : Core::LocationRange? = nil)
      super(location)
    end

    def initialize(location : Core::LocationRange? = nil, &block : FormattingPrinter ->)
      super(location)
      @proc = block
    end

    def passed? : Bool
      false
    end

    def try_raise : Nil
      raise AssertionFailed.new(self)
    end

    def format(printer : Formatters::Printer) : Nil
      if proc = @proc
        proc.call(FormattingPrinter.new(printer))
      elsif message = @message
        printer.print_value do |io|
          io << message
        end
      else
        printer << "Failed"
      end
    end

    def to_s(io : IO) : Nil
      format(Formatters::PlainPrinter.new(io))
    end
  end

  def self.passed(location : Core::LocationRange? = nil) : MatchData
    PassedMatchData.new(location)
  end

  def self.failed(message : String, location : Core::LocationRange? = nil) : MatchData
    FailedMatchData.new(message, location)
  end

  def self.failed(location : Core::LocationRange? = nil, &block : FormattingPrinter ->) : MatchData
    FailedMatchData.new(location, &block)
  end
end
