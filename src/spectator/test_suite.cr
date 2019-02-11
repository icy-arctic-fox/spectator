module Spectator
  # Encapsulates the tests to run and additional properties about them.
  # Use `#each` to enumerate over all tests in the suite.
  class TestSuite
    include Enumerable(Example)

    # Creates the test suite.
    # The example `group` provided will be run.
    def initialize(@group : ExampleGroup)
    end

    # Yields each example in the test suite.
    def each : Nil
      iterator.each do |example|
        yield example
      end
    end

    # Creates an iterator for the example group.
    private def iterator
      ExampleIterator.new(@group)
    end
  end
end
