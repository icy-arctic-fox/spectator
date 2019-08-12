require "./spec_helper"

describe Spectator::ExpectationFailed do
  describe "#expectation" do
    it "contains the expected value" do
      expectation = new_unsatisfied_expectation
      error = Spectator::ExpectationFailed.new(expectation)
      error.expectation.should eq(expectation)
    end
  end

  describe "#message" do
    it "is the same as the expectation's #actual_message" do
      expectation = new_unsatisfied_expectation
      error = Spectator::ExpectationFailed.new(expectation)
      error.message.should eq(expectation.failure_message)
    end
  end
end
