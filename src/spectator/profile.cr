require "json"
require "./example"

module Spectator
  # Information about the runtime of examples.
  class Profile
    include Indexable(Example)

    # Total length of time it took to run all examples in the test suite.
    getter total_time : Time::Span

    # Creates the profiling information.
    # The *slowest* results must already be sorted, longest time first.
    def initialize(@slowest : Array(Example), @total_time)
    end

    # Produces the profile from a report.
    def self.generate(examples, size = 10)
      finished = examples.select(&.finished?).to_a
      total_time = finished.sum(&.result.elapsed)
      sorted_examples = finished.sort_by(&.result.elapsed)
      slowest = sorted_examples.last(size).reverse
      new(slowest, total_time)
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
      @slowest.sum(&.result.elapsed)
    end

    # Percentage (from 0 to 100) of time the results in this profile took compared to all examples.
    def percentage
      time / @total_time * 100
    end

    # Produces a JSON fragment containing the profiling information.
    def to_json(json : JSON::Builder)
      json.object do
        json.field("examples") do
          json.array do
            @slowest.each(&.to_json(json))
          end
        end

        json.field("slowest", @slowest.max_of(&.result.elapsed).total_seconds)
        json.field("total", time.total_seconds)
        json.field("percentage", percentage)
      end
    end
  end
end
