require "./failed_result"

module Spectator
  # Outcome that indicates running an example generated an error.
  # This type of result occurs when an exception was raised.
  # This is different from a "failed" result
  # in that the error was not from a failed expectation.
  class ErroredResult < FailedResult
    # Indicates whether an error was encountered while running the example.
    # This will always be true for this type of result.
    def errored?
      true
    end
  end
end
