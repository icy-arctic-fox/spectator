module Spectator::Formatting
  # Formatter that outputs nothing.
  # Useful for testing and larger automated processes.
  class SilentFormatter < Formatter
    # Called when a test suite is starting to execute.
    def start_suite(suite : TestSuite)
      # ... crickets ...
    end

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    def end_suite(report : Report, profile : Profile?)
      # ... crickets ...
    end

    # Called before a test starts.
    def start_example(example : Example)
      # ... crickets ...
    end

    # Called when a test finishes.
    # The result of the test is provided.
    def end_example(result : Result)
      # ... crickets ...
    end
  end
end
