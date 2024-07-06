require "../assertion_failed"

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

    # The time it took to run the example.
    getter elapsed : Time::Span

    # The exception that caused the example to fail.
    # This will be nil if the example passed or was skipped.
    getter! exception : Exception

    def initialize(@status : Status, @elapsed : Time::Span, @exception = nil)
    end

    # Executes a block of code and creates a new result object based on the outcome.
    # If the block completed successfully, the returned result will be a pass.
    # If the block raised an exception, the returned result will be an error.
    # However, if an `AssertionFailed` exception is raised, the returned result will be a fail.
    def self.capture(&) : self
      exception = nil.as(Exception?)
      status = Status::Error # Safe default.

      elapsed = Time.measure do
        begin
          yield
          status = Status::Pass
        rescue ex : AssertionFailed
          status = Status::Fail
          exception = ex
        rescue ex
          status = Status::Error
          exception = ex
        end
      end

      new(status, elapsed, exception)
    end

    # Returns true if the example passed.
    def pass?
      @status.pass?
    end

    # Returns true if the example failed.
    # Errors are considered failures.
    def fail?
      !@status.pass? && !@status.skip?
    end
  end
end
