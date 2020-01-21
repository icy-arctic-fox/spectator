require "./example"

module Spectator
  # Includes all the logic for running example hooks,
  # the example code, and capturing a result.
  class RunnableExample < Example
    # Runs the example, hooks, and captures the result
    # and translates to a usable result.
    def run_impl : Result
      result = capture_result
      expectations = Harness.current.expectations
      translate_result(result, expectations)
    end

    # Runs all hooks and the example code.
    # A captured result is returned.
    private def capture_result
      context = group.context
      ResultCapture.new.tap do |result|
        context.run_before_hooks(self)
        run_example(result)
        @finished = true
        context.run_after_hooks(self)
        run_deferred(result) unless result.error
      end
    end

    # Runs the test code and captures the result.
    private def run_example(result)
      context = group.context
      wrapper = test_wrapper.around_hook(context)

      # Capture how long it takes to run the test code.
      result.elapsed = Time.measure do
        begin
          context.run_pre_conditions(self)
          wrapper.call
          context.run_post_conditions(self)
        rescue ex # Catch all errors and handle them later.
          result.error = ex
        end
      end
    end

    # Runs the deferred blocks of code and captures the result.
    private def run_deferred(result)
      result.elapsed += Time.measure do
        begin
          Harness.current.run_deferred
        rescue ex # Catch all errors and handle them later.
          result.error = ex
        end
      end
    end

    # Creates a result instance from captured result information.
    private def translate_result(result, expectations)
      case (error = result.error)
      when Nil
        # If no errors occurred, then the example ran successfully.
        SuccessfulResult.new(self, result.elapsed, expectations)
      when ExpectationFailed
        # If a required expectation fails, then a `ExpectationRailed` exception will be raised.
        FailedResult.new(self, result.elapsed, expectations, error)
      else
        # Any other exception that is raised is unexpected and is an errored result.
        ErroredResult.new(self, result.elapsed, expectations, error)
      end
    end

    # Utility class for storing parts of the result while the example is running.
    private class ResultCapture
      # Length of time that it took to run the test code.
      # This does not include hooks.
      property elapsed = Time::Span.zero

      # The error that occurred while running the test code.
      # If no error occurred, this will be nil.
      property error : Exception?
    end
  end
end
