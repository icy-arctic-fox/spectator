require "./example"

module Spectator
  abstract class RunnableExample < Example

    def run
      result = ResultCapture.new
      group.run_before_all_hooks
      group.run_before_each_hooks
      begin
        wrapped_capture_result(result).call
      ensure
        @finished = true
        group.run_after_each_hooks
        group.run_after_all_hooks
      end
      translate_result(result)
    end

    private def wrapped_capture_result(result)
      group.wrap_around_each_hooks do
        capture_result(result)
      end
    end

    private def capture_result(result)
      result.elapsed = Time.measure do
        begin
          run_instance
        rescue ex
          result.error = ex
        end
      end
    end

    private def translate_result(result)
      case (error = result.error)
      when Nil
        SuccessfulExampleResult.new(self, result.elapsed)
      when ExpectationFailedError
        FailedExampleResult.new(self, result.elapsed, error)
      else
        ErroredExampleResult.new(self, result.elapsed, error)
      end
    end

    protected abstract def run_instance

    private class ResultCapture
      property elapsed = Time::Span.new(nanoseconds: 0)
      property error : Exception?
    end
  end
end
