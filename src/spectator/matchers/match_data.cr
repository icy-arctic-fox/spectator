require "colorize"
require "../core/location_range"

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
  end

  struct FailedMatchData < MatchData
    getter message : String do
      color_enabled = Colorize.enabled?
      begin
        to_s
      ensure
        Colorize.enabled = color_enabled
      end
    end

    @proc : (IO ->)?

    def initialize(@message : String, location : Core::LocationRange? = nil)
      super(location)
    end

    def initialize(location : Core::LocationRange? = nil, &block : IO ->)
      super(location)
      @proc = block
    end

    def passed? : Bool
      false
    end

    def try_raise : Nil
      raise AssertionFailed.new(self)
    end

    def to_s(io : IO) : Nil
      if proc = @proc
        proc.call(io)
      elsif message = @message
        io << message
      else
        io << "Failed"
      end
    end
  end

  def self.passed(location : Core::LocationRange? = nil) : MatchData
    PassedMatchData.new(location)
  end

  def self.failed(message : String, location : Core::LocationRange? = nil) : MatchData
    FailedMatchData.new(message, location)
  end

  def self.failed(location : Core::LocationRange? = nil, &block : IO ->) : MatchData
    FailedMatchData.new(location, &block)
  end
end
