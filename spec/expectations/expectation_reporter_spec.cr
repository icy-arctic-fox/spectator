require "../spec_helper"

describe Spectator::Expectations::ExpectationReporter do
  describe "#report" do
    context "with raise flag set" do
      context "given a successful result" do
        it "stores the result" do
          result = new_successful_result
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          reporter.report(result)
          reporter.results.should contain(result)
        end
      end

      context "given a failed result" do
        it "raises and error" do
          result = new_failure_result
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          expect_raises(Spectator::ExpectationFailed) { reporter.report(result) }
        end

        it "stores the result" do
          result = new_failure_result
          reporter = Spectator::Expectations::ExpectationReporter.new(true)
          begin
            reporter.report(result)
          rescue
            # Ignore error, not testing that in this example.
          end
          reporter.results.should contain(result)
        end
      end
    end

    context "with raise flag not set" do
      context "given a successful result" do
        it "stores the result" do
          result = new_successful_result
          reporter = Spectator::Expectations::ExpectationReporter.new(false)
          reporter.report(result)
          reporter.results.should contain(result)
        end
      end

      context "given a failed result" do
        it "stores the result" do
          result = new_failure_result
          reporter = Spectator::Expectations::ExpectationReporter.new(false)
          reporter.report(result)
          reporter.results.should contain(result)
        end
      end
    end
  end

  describe "#results" do
    context "with no expectations" do
      it "is empty" do
        reporter = Spectator::Expectations::ExpectationReporter.new
        reporter.results.size.should eq(0)
      end
    end

    context "with multiple expectations" do
      it "contains all expectations" do
        result1 = new_successful_result
        result2 = new_failure_result
        reporter = Spectator::Expectations::ExpectationReporter.new(false)
        begin
          reporter.report(result1)
          reporter.report(result2)
        rescue
          # Ignore errors for this test.
        end
        reporter.results.should contain(result1)
        reporter.results.should contain(result2)
      end
    end
  end
end
