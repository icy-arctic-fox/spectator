module Spectator::Formatting
  # Interface for reporting test progress and results.
  #
  # The methods should be called in this order:
  # 1. `#start_suite`
  # 2. `#start_example`
  # 3. `#end_example`
  # 4. `#end_suite`
  #
  # Steps 2 and 3 are called for each example in the suite.
  abstract class Formatter
    # Called when a test suite is starting to execute.
    abstract def start_suite(suite : TestSuite)

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    # The *profile* flag is set to true when profiling results should be generated.
    abstract def end_suite(report : Report, profile : Bool)

    # Called before a test starts.
    abstract def start_example(example : Example)

    # Called when a test finishes.
    # The result of the test is provided.
    abstract def end_example(result : Result)
  end
end
