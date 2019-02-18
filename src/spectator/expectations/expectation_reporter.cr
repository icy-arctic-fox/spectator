module Spectator::Expectations
  # Tracks the expectations and their outcomes in an example.
  # A single instance of this class should be associated with one example.
  class ExpectationReporter
    # All expectations are stored in this array.
    # The initial capacity is set to one,
    # as that is the typical (and recommended)
    # number of expectations per example.
    @expectations = Array(Expectation).new(1)

    # Creates the reporter.
    # When the *raise_on_failure* flag is set to true,
    # which is the default, an exception will be raised
    # on the first failure that is reported.
    # To store failures and continue, set the flag to false.
    def initialize(@raise_on_failure = true)
    end

    # Stores the outcome of an expectation.
    # If the raise on failure flag is set to true,
    # then this method will raise an exception
    # when a failing result is given.
    def report(expectation : Expectation) : Nil
      @expectations << expectation
      raise ExpectationFailed.new(expectation) if !expectation.satisfied? && @raise_on_failure
    end

    # Returns the reported expectations from the example.
    # This should be run after the example has finished.
    def expectations : ExampleExpectations
      ExampleExpectations.new(@expectations)
    end
  end
end
