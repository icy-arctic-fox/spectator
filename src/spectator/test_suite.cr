module Spectator
  # Encapsulates the tests to run and additional properties about them.
  class TestSuite
    include Enumerable(Example)

    def initialize(@group : ExampleGroup)
    end

    def each
      iterator.each do |example|
        yield example
      end
    end

    private def iterator
      ExampleIterator.new(@group)
    end
  end
end
