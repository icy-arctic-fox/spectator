module Spectator
  # Information about the runtimes of examples.
  class Profile
    include Indexable(Result)

    # Total length of time it took to run all examples in the test suite.
    getter total_time : Time::Span

    # Creates the profiling information.
    # The *slowest* results must already be sorted, longest time first.
    private def initialize(@slowest : Array(FinishedResult), @total_time)
    end

    # Number of results in the profile.
    def size
      @slowest.size
    end

    # Retrieves a result at the specified index.
    def unsafe_fetch(index)
      @slowest.unsafe_fetch(index)
    end

    # Length of time it took to run the results in the profile.
    def time
      @slowest.sum(&.elapsed)
    end

    # Percentage (from 0 to 1) of time the results in this profile took compared to all examples.
    def percentage
      time / @total_time
    end

    # Produces the profile from a report.
    def self.generate(report, size = 10)
      results = report.compact_map(&.as?(FinishedResult))
      sorted_results = results.sort_by(&.elapsed)
      slowest = sorted_results.last(size).reverse
      self.new(slowest, report.example_runtime)
    end
  end
end
