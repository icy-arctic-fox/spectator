require "./expectation"

module Spectator::Expectations
  # Collection of expectations from an example.
  class ExampleExpectations
    include Enumerable(Expectation)

    # Creates the collection.
    def initialize(@expectations : Array(Expectation))
    end

    # Iterates through all expectations.
    def each
      @expectations.each do |expectation|
        yield expectation
      end
    end

    # Returns a collection of only the satisfied expectations.
    def satisfied : Enumerable(Expectation)
      @expectations.select(&.satisfied?)
    end

    # Iterates over only the satisfied expectations.
    def each_satisfied
      @expectations.each do |expectation|
        yield expectation if expectation.satisfied?
      end
    end

    # Returns a collection of only the unsatisfied expectations.
    def unsatisfied : Enumerable(Expectation)
      @expectations.reject(&.satisfied?)
    end

    # Iterates over only the unsatisfied expectations.
    def each_unsatisfied
      @expectations.each do |expectation|
        yield expectation unless expectation.satisfied?
      end
    end

    # Determines whether the example was successful
    # based on if all expectations were satisfied.
    def successful?
      @expectations.all?(&.satisfied?)
    end

    # Determines whether the example failed
    # based on if any expectations were not satisfied.
    def failed?
      !successful?
    end

    # Creates the JSON representation of the expectations.
    def to_json(json : ::JSON::Builder)
      json.array do
        each &.to_json(json)
      end
    end
  end
end
