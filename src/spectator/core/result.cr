module Spectator::Core
  enum Status
    Pass
    Fail
    Error
    Skip
  end

  # Information detailing the outcome of running an example.
  struct Result
    # The status of the example.
    getter status : Status

    # The exception that caused the example to fail.
    # This will be nil if the example passed or was skipped.
    getter! exception : Exception

    def initialize(@status : Status, @exception = nil)
    end

    def self.capture(&) : self
      begin
        yield
        new(:pass)
      rescue ex
        new(:error, ex)
      end
    end

    def pass?
      @status.pass?
    end

    def fail?
      !@status.pass? && !@status.skip?
    end
  end
end
