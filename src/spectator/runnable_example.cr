require "./example"

module Spectator
  # Common base for all examples that can be run.
  # This class includes all the logic for running example hooks,
  # the example code, and capturing a result.
  # Sub-classes need to implement the `#run_instance` method.
  abstract class RunnableExample < Example
    # Runs the example, hooks, and captures the result.
    def run_inner : Result
      result = ResultCapture.new
      begin
        run_before_hooks
        wrapped_capture_result(result).call
      ensure
        run_after_hooks
      end
      expectations = Internals::Harness.current.expectation_results
      translate_result(result, expectations)
    end

    # Runs the actual test code.
    private abstract def run_instance

    # Runs the hooks that should be performed before starting the test code.
    private def run_before_hooks
      group.run_before_all_hooks
      group.run_before_each_hooks
    end

    # Runs the hooks that should be performed after the test code finishes.
    private def run_after_hooks
      group.run_after_each_hooks
      group.run_after_all_hooks
    rescue ex
      # TODO: Pass along error to result.
    end

    # Creates a proc that runs the test code
    # and captures the result.
    private def wrapped_capture_result(result)
      # Wrap the method that runs and captures
      # the test code with the around-each hooks.
      group.wrap_around_each_hooks do
        # Pass along the result capture utility.
        capture_result(result)
      end
    end

    # Runs the test code and captures the result.
    private def capture_result(result)
      # Capture how long it takes to run the test code.
      result.elapsed = Time.measure do
        begin
          # Actually go run the example code.
          run_instance
        rescue ex # Catch all errors and handle them later.
          result.error = ex
        end
      end
    end

    private def translate_result(result, expectations)
      case (error = result.error)
      when Nil
        SuccessfulResult.new(self, result.elapsed, expectations)
      when ExpectationFailed
        FailedResult.new(self, result.elapsed, expectations, error)
      else
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
