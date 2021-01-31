require "./error_result"
require "./expectation"
require "./mocks"
require "./pass_result"
require "./result"

module Spectator
  # Helper class that acts as a gateway between test code and the framework.
  # This is essentially an "example runner."
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

    getter mocks = Mocks::Registry.new

    # Wraps an example with a harness and runs test code.
    # A block provided to this method is considered to be the test code.
    # The value of `.current` is set to the harness for the duration of the test.
    # It will be reset after the test regardless of the outcome.
    # The result of running the test code will be returned.
    def self.run : Result
      harness = new
      previous = @@current
      @@current = harness
      result = harness.run { yield }
      @@current = previous
      result
    end

    @deferred = Deque(->).new

    # Runs test code and produces a result based on the outcome.
    # The test code should be called from within the block given to this method.
    def run : Result
      outcome = capture { yield }
      run_deferred # TODO: Handle errors in deferred blocks.
      translate(*outcome)
    end

    def report(expectation : Expectation) : Nil
      Log.debug { "Reporting expectation #{expectation}" }
      raise ExpectationFailed.new(expectation) if expectation.failed?
    end

    # Stores a block of code to be executed later.
    # All deferred blocks run just before the `#run` method completes.
    def defer(&block) : Nil
      @deferred << block
    end

    # Yields to run the test code and returns information about the outcome.
    # Returns a tuple with the elapsed time and an error if one occurred (otherwise nil).
    private def capture
      error = nil.as(Exception?)
      elapsed = Time.measure do
        begin
          yield
        rescue e
          error = e
        end
      end
      {elapsed, error}
    end

    # Translates the outcome of running a test to a result.
    # Takes the *elapsed* time and a possible *error* from the test.
    # Returns a type of `Result`.
    private def translate(elapsed, error) : Result
      example = Example.current # TODO: Remove this.
      case error
      when nil
        PassResult.new(example, elapsed)
      when ExpectationFailed
        FailResult.new(example, elapsed, error)
      else
        ErrorResult.new(example, elapsed, error)
      end
    end

    # Runs all deferred blocks.
    private def run_deferred : Nil
      @deferred.each(&.call)
      @deferred.clear
    end
  end
end
