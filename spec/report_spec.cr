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

def new_report(successful_count = 5, failed_count = 5, error_count = 5, pending_count = 5, overhead_time = 1_000_000i64)
  results = [] of Spectator::Result
  successful_count.times { results << new_passing_result }
  failed_count.times { results << new_failure_result }
  error_count.times { results << new_failure_result(Spectator::ErroredResult) }
  pending_count.times { results << new_pending_result }

  example_runtime = results.compact_map(&.as?(Spectator::FinishedResult)).sum(&.elapsed)
  total_runtime = example_runtime + Time::Span.new(nanoseconds: overhead_time)
  Spectator::Report.new(results, total_runtime)
end

describe Spectator::Report do
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
