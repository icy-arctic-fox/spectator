module Spectator
  # Encapsulates the tests to run and additional properties about them.
  # Use `#each` to enumerate over all tests in the suite.
  class TestSuite
    include Enumerable(Example)

    # Creates the test suite.
    # The example *group* provided will be run.
    # The *filter* identifies which examples to run from the *group*.
    def initialize(@group : ExampleGroup, @filter : ExampleFilter)
    end

    # Yields each example in the test suite.
    def each : Nil
      iterator.each do |example|
        yield example if @filter.includes?(example)
      end
    end

    # Creates an iterator for the example group.
    private def iterator
      ExampleIterator.new(@group)
    end
  end
end
