require "../spec_helper"

describe Spectator::Expectations::ExpectationReporter do
  describe "#report" do
    context "with raise flag set" do
      context "given a satisfied expectation" do
        it "stores the result" do
          expectation = new_satisfied_expectation
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          reporter.report(expectation)
          reporter.expectations.should contain(expectation)
        end
      end

      context "given a unsatisfied expectation" do
        it "raises and error" do
          expectation = new_unsatisfied_expectation
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          expect_raises(Spectator::ExpectationFailed) { reporter.report(expectation) }
        end

        it "stores the expectation" do
          expectation = new_unsatisfied_expectation
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          begin
            reporter.report(expectation)
          rescue
            # Ignore error, not testing that in this example.
          end
          reporter.expectations.should contain(expectation)
        end
      end
    end

    context "with raise flag not set" do
      context "given a satisfied expectation" do
        it "stores the expectation" do
          expectation = new_satisfied_expectation
          reporter = Spectator::Expectations::ExpectationReporter.new(false)
          reporter.report(expectation)
          reporter.expectations.should contain(expectation)
        end
      end

      context "given a unsatisfied expectation" do
        it "stores the expectation" do
          expectation = new_unsatisfied_expectation
          reporter = Spectator::Expectations::ExpectationReporter.new(false)
          reporter.report(expectation)
          reporter.expectations.should contain(expectation)
        end
      end
    end
  end

  describe "#expectations" do
    context "with no expectations" do
      it "is empty" do
        reporter = Spectator::Expectations::ExpectationReporter.new
        reporter.expectations.size.should eq(0)
      end
    end

    context "with multiple expectations" do
      it "contains all expectations" do
        expectation1 = new_satisfied_expectation
        expectation2 = new_unsatisfied_expectation
        reporter = Spectator::Expectations::ExpectationReporter.new(false)
        begin
          reporter.report(expectation1)
          reporter.report(expectation2)
        rescue
          # Ignore errors for this test.
        end
        reporter.expectations.should contain(expectation1)
        reporter.expectations.should contain(expectation2)
      end
    end
  end
end
