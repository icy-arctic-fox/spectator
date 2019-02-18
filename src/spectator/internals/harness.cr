module Spectator::Internals
  # Helper class that acts as a gateway between example code and the test framework.
  # Every example must be invoked by passing it to `#run`.
  # This sets up the harness so that the example code can use it.
  # The test framework does the following:
  # ```
  # result = Harness.run(example)
  # # Do something with the result.
  # ```
  # Then from the example code, the harness can be accessed via `#current` like so:
  # ```
  # harness = ::Spectator::Internals::Harness.current
  # # Do something with the harness.
  # ```
  # Of course, the end-user shouldn't see this or work directly with the harness.
  # Instead, methods the user calls can access it.
  # For instance, an expectation reporting a result.
  class Harness
    # Retrieves the harness for the current running example.
    class_getter! current : self

    # Wraps an example with a harness and runs the example.
    # The `#current` harness will be set
    # prior to running the example, and reset after.
    # The *example* argument will be the example to run.
    # The result returned from `Example#run` will be returned.
    def self.run(example : Example) : Result
      @@current = new(example)
      example.run
    ensure
      @@current = nil
    end

    # Retrieves the current running example.
    getter example : Example

    # Reports the outcome of an expectation.
    # An exception will be raised when a failing result is given.
    def report_expectation(expectation : Expectations::Expectation) : Nil
      @reporter.report(expectation)
    end

    # Generates the reported expectations from the example.
    # This should be run after the example has finished.
    def expectations : Expectations::ExampleExpectations
      @reporter.expectations
    end

    # Creates a new harness.
    # The example the harness is for should be passed in.
    private def initialize(@example)
      @reporter = Expectations::ExpectationReporter.new
    end
  end
end
