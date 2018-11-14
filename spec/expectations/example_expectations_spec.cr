require "../spec_helper"

describe Spectator::Expectations::ExampleExpectations do
  describe "#each" do
    it "yields all expectations" do
      tuple = generate_expectations(5, 5)
      expectations = [] of Spectator::Expectations::Expectation
      tuple[:reporter].expectations.each { |expectation| expectations << expectation }
      # Expectations might not be in the same order.
      # Just check if if the arrays contain the same items.
      expectations.size.should eq(tuple[:expectations].size)
      (expectations - tuple[:expectations]).empty?.should be_true
    end
  end

  describe "#satisfied" do
    it "returns only satisfied expectations" do
      tuple = generate_expectations(5, 5)
      expectations = tuple[:reporter].expectations
      expectations.satisfied.all?(&.satisfied?).should be_true
    end

    it "returns the correct expectations" do
      tuple = generate_expectations(5, 5)
      expectations = tuple[:reporter].expectations
      satisfied = expectations.satisfied.to_a
      satisfied.size.should eq(5)
      (satisfied - tuple[:satisfied]).empty?.should be_true
    end

    context "with all satisfied expectations" do
      it "returns all expectations" do
        tuple = generate_expectations(5, 0)
        expectations = tuple[:reporter].expectations
        expectations.satisfied.size.should eq(tuple[:satisfied].size)
      end
    end

    context "with all unsatisfied expectations" do
      it "returns an empty collection" do
        tuple = generate_expectations(0, 5)
        expectations = tuple[:reporter].expectations
        expectations.satisfied.size.should eq(0)
      end
    end
  end

  describe "#each_satisfied" do
    it "yields only satisfied expectations" do
      tuple = generate_expectations(5, 5)
      expectations = [] of Spectator::Expectations::Expectation
      tuple[:reporter].expectations.each_satisfied { |expectation| expectations << expectation }
      # Expectations might not be in the same order.
      # Just check if if the arrays contain the same items.
      expectations.size.should eq(tuple[:satisfied].size)
      (expectations - tuple[:satisfied]).empty?.should be_true
    end

    context "with all satisfied expectations" do
      it "yields all expectations" do
        tuple = generate_expectations(0, 5)
        expectations = [] of Spectator::Expectations::Expectation
        tuple[:reporter].expectations.each_satisfied { |expectation| expectations << expectation }
        expectations.size.should eq(tuple[:satisfied].size)
      end
    end

    context "with all unsatisfied expectations" do
      it "yields nothing" do
        tuple = generate_expectations(0, 5)
        expectations = [] of Spectator::Expectations::Expectation
        tuple[:reporter].expectations.each_satisfied { |expectation| expectations << expectation }
        expectations.empty?.should be_true
      end
    end
  end

  describe "#unsatisfied" do
    it "returns only unsatisfied expectations" do
      tuple = generate_expectations(5, 5)
      expectations = tuple[:reporter].expectations
      expectations.unsatisfied.all?(&.satisfied?).should be_false
    end

    it "returns the correct expectations" do
      tuple = generate_expectations(5, 5)
      expectations = tuple[:reporter].expectations
      unsatisfied = expectations.unsatisfied.to_a
      unsatisfied.size.should eq(5)
      (unsatisfied - tuple[:unsatisfied]).empty?.should be_true
    end

    context "with all satisfied expectations" do
      it "returns an empty collection" do
        tuple = generate_expectations(5, 0)
        expectations = tuple[:reporter].expectations
        expectations.unsatisfied.size.should eq(0)
      end
    end

    context "with all unsatisfied expectations" do
      it "returns all expectations" do
        tuple = generate_expectations(0, 5)
        expectations = tuple[:reporter].expectations
        expectations.unsatisfied.size.should eq(tuple[:unsatisfied].size)
      end
    end
  end

  describe "#each_unsatisfied" do
    it "yields only unsatisfied expectations" do
      tuple = generate_expectations(5, 5)
      expectations = [] of Spectator::Expectations::Expectation
      tuple[:reporter].expectations.each_unsatisfied { |expectation| expectations << expectation }
      # Expectations might not be in the same order.
      # Just check if if the arrays contain the same items.
      expectations.size.should eq(tuple[:unsatisfied].size)
      (expectations - tuple[:unsatisfied]).empty?.should be_true
    end

    context "with all satisfied expectations" do
      it "yields nothing" do
        tuple = generate_expectations(5, 0)
        expectations = [] of Spectator::Expectations::Expectation
        tuple[:reporter].expectations.each_unsatisfied { |expectation| expectations << expectation }
        expectations.empty?.should be_true
      end
    end

    context "with all unsatisfied expectations" do
      it "yields all expectations" do
        tuple = generate_expectations(0, 5)
        expectations = [] of Spectator::Expectations::Expectation
        tuple[:reporter].expectations.each_unsatisfied { |expectation| expectations << expectation }
        expectations.size.should eq(tuple[:unsatisfied].size)
      end
    end
  end

  describe "#successful?" do
    context "with all satisfied expectations" do
      it "is true" do
        tuple = generate_expectations(5, 0)
        expectations = tuple[:reporter].expectations
        expectations.successful?.should be_true
      end
    end

    context "with one unsatisfied expectation" do
      it "is false" do
        tuple = generate_expectations(5, 1)
        expectations = tuple[:reporter].expectations
        expectations.successful?.should be_false
      end
    end

    context "with one satisfied expectation" do
      it "is false" do
        tuple = generate_expectations(1, 5)
        expectations = tuple[:reporter].expectations
        expectations.successful?.should be_false
      end
    end

    context "with all unsatisfied expectations" do
      it "is false" do
        tuple = generate_expectations(0, 5)
        expectations = tuple[:reporter].expectations
        expectations.successful?.should be_false
      end
    end
  end

  describe "#failed?" do
    context "with all satisfied expectations" do
      it "is false" do
        tuple = generate_expectations(5, 0)
        expectations = tuple[:reporter].expectations
        expectations.failed?.should be_false
      end
    end

    context "with one unsatisfied expectation" do
      it "is true" do
        tuple = generate_expectations(5, 1)
        expectations = tuple[:reporter].expectations
        expectations.failed?.should be_true
      end
    end

    context "with one satisfied expectation" do
      it "is true" do
        tuple = generate_expectations(1, 5)
        expectations = tuple[:reporter].expectations
        expectations.failed?.should be_true
      end
    end

    context "with all unsatisfied expectations" do
      it "is true" do
        tuple = generate_expectations(0, 5)
        expectations = tuple[:reporter].expectations
        expectations.failed?.should be_true
      end
    end
  end
end
