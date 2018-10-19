module Spectator::Expectations
  # Collection of results of expectations from an example.
  class ExpectationResults
    include Enumerable(Expectation::Result)

    # Creates the collection.
    def initialize(@results : Array(Expectation::Result))
    end

    # Iterates through all expectation results.
    def each
      @results.each do |result|
        yield result
      end
    end

    # Returns a collection of only the successful expectation results.
    def successes : Enumerable(Expectation::Result)
      @results.select(&.successful?)
    end

    # Iterates over only the successful expectation results.
    def each_success
      @results.each do |result|
        yield result if result.successful?
      end
    end

    # Returns a collection of only the failed expectation results.
    def failures : Enumerable(Expectation::Result)
      @results.select(&.failure?)
    end

    # Iterates over only the failed expectation results.
    def each_failure
      @results.each do |result|
        yield result if result.failure?
      end
    end

    # Determines whether the example was successful
    # based on if all expectations were satisfied.
    def successful?
      @results.all?(&.successful?)
    end

    # Determines whether the example failed
    # based on if any expectations were not satisfied.
    def failed?
      @results.any?(&.failure?)
    end
  end
end
