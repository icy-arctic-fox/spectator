module Spectator::Internals
  # Helper class that acts as a gateway between example code and the test framework.
  # Every example run must be called with `#run`.
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
    # The `example` argument will be the example to run.
    # The result returned from `Example#run` will be returned.
    def self.run(example : Example) : Result
      @@current = new(example)
      result = example.run
      @@current = nil
      result
    end

    # Retrieves the current running example.
    getter example : Example

    # Provides access to the expectation reporter.
    getter reporter = Expectations::ExpectationReporter.new

    # Creates a new harness.
    # The example the harness is for should be passed in.
    private def initialize(@example)
    end
  end
end
