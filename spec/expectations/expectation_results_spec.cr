require "../spec_helper"

describe Spectator::Expectations::ExpectationResults do
  describe "#each" do
    it "yields all results" do
      tuple = generate_results(5, 5)
      results = [] of Spectator::Expectations::Expectation::Result
      tuple[:reporter].results.each { |result| results << result }
      # Results might not be in the same order.
      # Just check if if the arrays contain the same items.
      results.size.should eq(tuple[:results].size)
      (results - tuple[:results]).empty?.should be_true
    end
  end

  describe "#successes" do
    it "returns only successful results" do
      tuple = generate_results(5, 5)
      results = tuple[:reporter].results
      results.successes.all?(&.successful?).should be_true
    end

    it "returns the correct results" do
      tuple = generate_results(5, 5)
      results = tuple[:reporter].results
      successful = results.successes.to_a
      successful.size.should eq(5)
      (successful - tuple[:successful]).empty?.should be_true
    end

    context "with all successful results" do
      it "returns all results" do
        tuple = generate_results(5, 0)
        results = tuple[:reporter].results
        results.successes.size.should eq(tuple[:successful].size)
      end
    end

    context "with all failure results" do
      it "returns an empty collection" do
        tuple = generate_results(0, 5)
        results = tuple[:reporter].results
        results.successes.size.should eq(0)
      end
    end
  end

  describe "#each_success" do
    it "yields only successful results" do
      tuple = generate_results(5, 5)
      results = [] of Spectator::Expectations::Expectation::Result
      tuple[:reporter].results.each_success { |result| results << result }
      # Results might not be in the same order.
      # Just check if if the arrays contain the same items.
      results.size.should eq(tuple[:successful].size)
      (results - tuple[:successful]).empty?.should be_true
    end

    context "with all successful results" do
      it "yields all results" do
        tuple = generate_results(0, 5)
        results = [] of Spectator::Expectations::Expectation::Result
        tuple[:reporter].results.each_success { |result| results << result }
        results.size.should eq(tuple[:successful].size)
      end
    end

    context "with all failure results" do
      it "yields nothing" do
        tuple = generate_results(0, 5)
        results = [] of Spectator::Expectations::Expectation::Result
        tuple[:reporter].results.each_success { |result| results << result }
        results.empty?.should be_true
      end
    end
  end

  describe "#failures" do
    it "returns only failed results" do
      tuple = generate_results(5, 5)
      results = tuple[:reporter].results
      results.failures.all?(&.failure?).should be_true
    end

    it "returns the correct results" do
      tuple = generate_results(5, 5)
      results = tuple[:reporter].results
      failures = results.failures.to_a
      failures.size.should eq(5)
      (failures - tuple[:failures]).empty?.should be_true
    end

    context "with all successful results" do
      it "returns an empty collection" do
        tuple = generate_results(5, 0)
        results = tuple[:reporter].results
        results.failures.size.should eq(0)
      end
    end

    context "with all failure results" do
      it "returns all results" do
        tuple = generate_results(0, 5)
        results = tuple[:reporter].results
        results.failures.size.should eq(tuple[:failures].size)
      end
    end
  end

  describe "#each_failure" do
    it "yields only failed results" do
      tuple = generate_results(5, 5)
      results = [] of Spectator::Expectations::Expectation::Result
      tuple[:reporter].results.each_failure { |result| results << result }
      # Results might not be in the same order.
      # Just check if if the arrays contain the same items.
      results.size.should eq(tuple[:failures].size)
      (results - tuple[:failures]).empty?.should be_true
    end

    context "with all successful results" do
      it "yields nothing" do
        tuple = generate_results(5, 0)
        results = [] of Spectator::Expectations::Expectation::Result
        tuple[:reporter].results.each_failure { |result| results << result }
        results.empty?.should be_true
      end
    end

    context "with all failure results" do
      it "yields all results" do
        tuple = generate_results(0, 5)
        results = [] of Spectator::Expectations::Expectation::Result
        tuple[:reporter].results.each_failure { |result| results << result }
        results.size.should eq(tuple[:failures].size)
      end
    end
  end

  describe "#successful?" do
    context "with all successful results" do
      it "is true" do
        tuple = generate_results(5, 0)
        results = tuple[:reporter].results
        results.successful?.should be_true
      end
    end

    context "with one failure result" do
      it "is false" do
        tuple = generate_results(5, 1)
        results = tuple[:reporter].results
        results.successful?.should be_false
      end
    end

    context "with one successful result" do
      it "is false" do
        tuple = generate_results(1, 5)
        results = tuple[:reporter].results
        results.successful?.should be_false
      end
    end

    context "with all failure results" do
      it "is false" do
        tuple = generate_results(0, 5)
        results = tuple[:reporter].results
        results.successful?.should be_false
      end
    end
  end

  describe "#failed?" do
    context "with all successful results" do
      it "is false" do
        tuple = generate_results(5, 0)
        results = tuple[:reporter].results
        results.failed?.should be_false
      end
    end

    context "with one failure result" do
      it "is true" do
        tuple = generate_results(5, 1)
        results = tuple[:reporter].results
        results.failed?.should be_true
      end
    end

    context "with one successful result" do
      it "is true" do
        tuple = generate_results(1, 5)
        results = tuple[:reporter].results
        results.failed?.should be_true
      end
    end

    context "with all failure results" do
      it "is true" do
        tuple = generate_results(0, 5)
        results = tuple[:reporter].results
        results.failed?.should be_true
      end
    end
  end
end
