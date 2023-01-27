require "./error_result"
require "./example_failed"
require "./example_pending"
require "./expectation"
require "./expectation_failed"
require "./multiple_expectations_failed"
require "./pass_result"
require "./result"

module Spectator
  # Helper class that acts as a gateway between test code and the framework.
  #
  # Test code should be wrapped with a call to `.run`.
  # This class will catch all errors raised by the test code.
  # Errors caused by failed assertions (`AssertionFailed`) are translated to failed results (`FailResult`).
  # Errors not caused by assertions are translated to error results (`ErrorResult`).
  #
  # Every runnable example should invoke the test code by calling `.run`.
  # This sets up the harness so that the test code can use it.
  # The framework does the following:
  # ```
  # result = Harness.run { run_example_code }
  # # Do something with the result.
  # ```
  #
  # Then from the test code, the harness can be accessed via `.current` like so:
  # ```
  # harness = ::Spectator::Harness.current
  # # Do something with the harness.
  # ```
  #
  # Of course, the end-user shouldn't see this or work directly with the harness.
  # Instead, methods the test calls can access it.
  # For instance, an expectation reporting a result.
  class Harness
    Log = ::Spectator::Log.for(self)

    # Retrieves the harness for the current running example.
    class_getter! current : self

    # Wraps an example with a harness and runs test code.
    # A block provided to this method is considered to be the test code.
    # The value of `.current` is set to the harness for the duration of the test.
    # It will be reset after the test regardless of the outcome.
    # The result of running the test code will be returned.
    def self.run(&) : Result
      with_harness do |harness|
        harness.run { yield }
      end
    end

    # Instantiates a new harness and yields it.
    # The `.current` harness is set to the new harness for the duration of the block.
    # `.current` is reset to the previous value (probably nil) afterwards, even if the block raises.
    # The result of the block is returned.
    private def self.with_harness(&)
      previous = @@current
      begin
        @@current = harness = new
        yield harness
      ensure
        @@current = previous
      end
    end

    @deferred = Deque(->).new
    @cleanup = Deque(->).new
    @expectations = [] of Expectation
    @aggregate : Array(Expectation)? = nil

    # Runs test code and produces a result based on the outcome.
    # The test code should be called from within the block given to this method.
    def run(&) : Result
      elapsed, error = capture { yield }
      elapsed2, error2 = capture { run_deferred }
      run_cleanup
      translate(elapsed + elapsed2, error || error2)
    end

    def report(expectation : Expectation) : Bool
      Log.debug { "Reporting expectation #{expectation}" }
      @expectations << expectation

      # TODO: Move this out of harness, maybe to `Example`.
      Example.current.name = expectation.description unless Example.current.name?

      if expectation.failed?
        raise ExpectationFailed.new(expectation, expectation.failure_message) unless (aggregate = @aggregate)
        aggregate << expectation
        false
      else
        true
      end
    end

    # Stores a block of code to be executed later.
    # All deferred blocks run just before the `#run` method completes.
    def defer(&block) : Nil
      @deferred << block
    end

    # Stores a block of code to be executed at cleanup.
    # Cleanup is run after everything else, even deferred blocks.
    # Each cleanup step is wrapped in error handling so that one failure doesn't block the next ones.
    def cleanup(&block) : Nil
      @cleanup << block
    end

    def aggregate_failures(label = nil, &)
      previous = @aggregate
      @aggregate = aggregate = [] of Expectation
      begin
        yield.tap do
          # If there's an nested aggregate (for some reason), allow the top-level one to handle things.
          check_aggregate(aggregate, label) unless previous
        end
      ensure
        @aggregate = previous
      end
    end

    private def check_aggregate(aggregate, label)
      failures = aggregate.select(&.failed?)
      case failures.size
      when 0 then return
      when 1
        expectation = failures.first
        raise ExpectationFailed.new(expectation, expectation.failure_message)
      else
        message = "Got #{failures.size} failures from failure aggregation block"
        message += " \"#{label}\"" if label
        raise MultipleExpectationsFailed.new(failures, message)
      end
    end

    # Yields to run the test code and returns information about the outcome.
    # Returns a tuple with the elapsed time and an error if one occurred (otherwise nil).
    private def capture(&) : Tuple(Time::Span, Exception?)
      error = nil
      elapsed = Time.measure do
        error = catch { yield }
      end
      {elapsed, error}
    end

    # Yields to run a block of code and captures exceptions.
    # If the block of code raises an error, the error is caught and returned.
    # If the block doesn't raise an error, then nil is returned.
    private def catch(&) : Exception?
      yield
    rescue e
      e
    else
      nil
    end

    # Translates the outcome of running a test to a result.
    # Takes the *elapsed* time and a possible *error* from the test.
    # Returns a type of `Result`.
    private def translate(elapsed, error) : Result
      case error
      when nil
        PassResult.new(elapsed, @expectations)
      when ExampleFailed
        FailResult.new(elapsed, error, @expectations)
      when ExamplePending
        PendingResult.new(error.message || PendingResult::DEFAULT_REASON, error.location, elapsed, @expectations)
      else
        ErrorResult.new(elapsed, error, @expectations)
      end
    end

    # Runs all deferred blocks.
    # This method executes code from tests and may raise an error.
    # It should be wrapped in a call to `#capture`.
    private def run_deferred
      Log.debug { "Running deferred operations" }
      @deferred.each(&.call)
    end

    # Invokes all cleanup callbacks.
    # Each callback is wrapped with error handling.
    private def run_cleanup
      Log.debug { "Running cleanup" }
      @cleanup.each do |callback|
        callback.call
      rescue e
        Log.error(exception: e) { "Encountered error during cleanup" }
      end
    end
  end
end
