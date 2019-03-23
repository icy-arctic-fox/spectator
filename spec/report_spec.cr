require "./spec_helper"

def new_passing_result
  example = PassingExample.create
  elapsed = Time::Span.new(nanoseconds: 1_000_000)
  expectations = Spectator::Expectations::ExampleExpectations.new([] of Spectator::Expectations::Expectation)
  Spectator::SuccessfulResult.new(example, elapsed, expectations)
end

def new_failure_result(result_type : Spectator::Result.class = Spectator::FailedResult)
  example = FailingExample.create # Doesn't matter what type of example is used here.
  elapsed = Time::Span.new(nanoseconds: 1_000_000)
  expectations = Spectator::Expectations::ExampleExpectations.new([] of Spectator::Expectations::Expectation)
  error = Exception.new("foobar")
  result_type.new(example, elapsed, expectations, error)
end

def new_results(successful_count = 5, failed_count = 5, error_count = 5, pending_count = 5)
  total = successful_count + failed_count + error_count + pending_count
  results = Array(Spectator::Result).new(total)
  successful_count.times { results << new_passing_result }
  failed_count.times { results << new_failure_result }
  error_count.times { results << new_failure_result(Spectator::ErroredResult) }
  pending_count.times { results << new_pending_result }
  results
end

def new_report(successful_count = 5, failed_count = 5, error_count = 5, pending_count = 5, overhead_time = 1_000_000i64, fail_blank = false)
  results = new_results(successful_count, failed_count, error_count, pending_count)
  example_runtime = results.compact_map(&.as?(Spectator::FinishedResult)).sum(&.elapsed)
  total_runtime = example_runtime + Time::Span.new(nanoseconds: overhead_time)
  Spectator::Report.new(results, total_runtime, fail_blank: fail_blank)
end

describe Spectator::Report do
  describe "#initialize(results)" do
    describe "#runtime" do
      it "is the sum of all results' runtimes" do
        results = new_results
        runtime = results.compact_map(&.as?(Spectator::FinishedResult)).sum(&.elapsed)
        report = Spectator::Report.new(results)
        report.runtime.should eq(runtime)
      end
    end
  end

  describe "#each" do
    it "yields all results" do
      results = new_results
      report = Spectator::Report.new(results)
      # The `#each` method is tested through `Enumerable#to_a`.
      report.to_a.should eq(results)
    end
  end

  describe "#runtime" do
    it "is the expected value" do
      span = Time::Span.new(10, 10, 10)
      report = Spectator::Report.new([] of Spectator::Result, span)
      report.runtime.should eq(span)
    end
  end

  describe "#example_count" do
    it "is the expected value" do
      report = new_report(5, 4, 3, 2)
      report.example_count.should eq(14)
    end
  end

  describe "#examples_ran" do
    it "is the number of non-skipped examples" do
      report = new_report(5, 4, 3, 2)
      report.examples_ran.should eq(12)
    end
  end

  describe "#successful_count" do
    it "is the expected value" do
      report = new_report(5, 4, 3, 2)
      report.successful_count.should eq(5)
    end
  end

  describe "#failed_count" do
    it "is the expected value" do
      report = new_report(5, 4, 3, 2)
      report.failed_count.should eq(7)
    end
  end

  describe "#error_count" do
    it "is the expected value" do
      report = new_report(5, 4, 3, 2)
      report.error_count.should eq(3)
    end
  end

  describe "#pending_count" do
    it "is the expected value" do
      report = new_report(5, 4, 3, 2)
      report.pending_count.should eq(2)
    end
  end

  describe "#remaining_count" do
    it "is the expected value" do
      results = [] of Spectator::Result
      remaining = 5
      report = Spectator::Report.new(results, Time::Span.zero, remaining)
      report.remaining_count.should eq(remaining)
    end
  end

  describe "#failed?" do
    context "with a failed test suite" do
      it "is true" do
        report = new_report(5, 4, 3, 2)
        report.failed?.should be_true
      end
    end

    context "with a passing test suite" do
      it "is false" do
        report = new_report(5, 0, 0, 0)
        report.failed?.should be_false
      end
    end

    context "with fail-blank enabled" do
      context "when no tests run" do
        it "is true" do
          report = new_report(0, 0, 0, 5, fail_blank: true)
          report.failed?.should be_true
        end
      end

      context "when tests run" do
        context "and there are failures" do
          it "is true" do
            report = new_report(5, 4, 3, 2, fail_blank: true)
            report.failed?.should be_true
          end
        end

        context "and there are no failures" do
          it "is false" do
            report = new_report(5, 0, 0, 2, fail_blank: true)
            report.failed?.should be_false
          end
        end
      end
    end
  end

  describe "#remaining?" do
    context "with remaining tests" do
      it "is true" do
        results = [] of Spectator::Result
        report = Spectator::Report.new(results, Time::Span.zero, 5)
        report.remaining?.should be_true
      end
    end

    context "without remaining tests" do
      it "is false" do
        results = [] of Spectator::Result
        report = Spectator::Report.new(results, Time::Span.zero, 0)
        report.remaining?.should be_false
      end
    end
  end

  describe "#failures" do
    it "returns the expected results" do
      results = Array.new(5) { new_failure_result.as(Spectator::Result) }
      report = Spectator::Report.new(results, Time::Span.zero)
      report.failures.to_a.should eq(results)
    end

    it "includes errors" do
      results = Array(Spectator::Result).new(5) do |index|
        if index.odd?
          new_failure_result
        else
          new_failure_result(Spectator::ErroredResult)
        end
      end
      report = Spectator::Report.new(results, Time::Span.zero)
      report.failures.to_a.should eq(results)
    end
  end

  describe "#errors" do
    it "returns the expected results" do
      results = Array.new(5) { new_failure_result(Spectator::ErroredResult).as(Spectator::Result) }
      report = Spectator::Report.new(results, Time::Span.zero)
      report.errors.to_a.should eq(results)
    end

    it "does not include failures" do
      results = Array(Spectator::Result).new(5) do |index|
        if index.odd?
          new_failure_result
        else
          new_failure_result(Spectator::ErroredResult)
        end
      end
      report = Spectator::Report.new(results, Time::Span.zero)
      errors_only = results.select(&.is_a?(Spectator::ErroredResult))
      report.errors.to_a.should eq(errors_only)
    end
  end

  describe "#example_runtime" do
    it "is the sum of all example run-times" do
      passing_results = Array.new(5) { new_passing_result }
      runtime = passing_results.sum(&.elapsed)
      results = passing_results.map(&.as(Spectator::Result))
      total_runtime = runtime + Time::Span.new(nanoseconds: 1_234_567)
      report = Spectator::Report.new(results, total_runtime)
      report.example_runtime.should eq(runtime)
    end
  end

  describe "#overhead_time" do
    it "is the difference between total runtime and the sum of all example run-times" do
      passing_results = Array.new(5) { new_passing_result }
      runtime = passing_results.sum(&.elapsed)
      results = passing_results.map(&.as(Spectator::Result))
      overhead = Time::Span.new(nanoseconds: 1_234_567)
      total_runtime = runtime + overhead
      report = Spectator::Report.new(results, total_runtime)
      report.overhead_time.should eq(overhead)
    end
  end
end
