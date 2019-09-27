require "./example"

module Spectator
  # Common base for all examples that can be run.
  # This class includes all the logic for running example hooks,
  # the example code, and capturing a result.
  # Sub-classes need to implement the `#what` and `#run_instance` methods.
  abstract class RunnableExample < Example
    # Runs the example, hooks, and captures the result
    # and translates to a usable result.
    def run_impl : Result
      result = capture_result
      expectations = Internals::Harness.current.expectations
      translate_result(result, expectations)
    end

    # Runs the actual test code.
    private abstract def run_instance

    # Runs the hooks that should be performed before starting the test code.
    private def run_before_hooks
      group.run_before_hooks
    rescue ex
      # If an error occurs in the before hooks, skip running the example.
      raise Exception.new("Error encountered while running before hooks", ex)
    end

    # Runs the hooks that should be performed after the test code finishes.
    private def run_after_hooks
      group.run_after_hooks
    rescue ex
      # If an error occurs in the after hooks, elevate it to abort testing.
      raise Exception.new("Error encountered while running after hooks", ex)
    end

    # Runs all hooks and the example code.
    # A captured result is returned.
    private def capture_result
      ResultCapture.new.tap do |result|
        # Get the proc that will call around-each hooks and the example.
        wrapper = wrap_run_example(result)

        run_before_hooks
        run_wrapper(wrapper)
        run_after_hooks
      end
    end

    private def run_wrapper(wrapper)
      wrapper.call
    rescue ex
      # If an error occurs calling the wrapper,
      # it means it came from the "around-each" hooks.
      # This is because the test code is completely wrapped with a begin/rescue block.
      raise Exception.new("Error encountered while running around hooks", ex)
    end

    # Creates a proc that runs the test code
    # and captures the result.
    private def wrap_run_example(result)
      # Wrap the method that runs and captures
      # the test code with the around-each hooks.
      group.wrap_around_each_hooks do
        run_example(result)
      end
    end

    # Runs the test code and captures the result.
    private def run_example(result)
      # Capture how long it takes to run the test code.
      result.elapsed = Time.measure do
        begin
          group.run_pre_conditions
          run_instance # Actually run the example code.
          group.run_post_conditions
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
