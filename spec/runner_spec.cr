require "./spec_helper"

# Creates a `Config` for Spectator that is suited for testing it.
def spectator_test_config(formatter : Spectator::Formatting::Formatter? = nil)
  Spectator::Config.new(formatter || Spectator::Formatting::SilentFormatter.new)
end

def new_test_suite
  example = PassingExample.create
  Spectator::TestSuite.new(example.group)
end

describe Spectator::Runner do
  describe "#run" do
    it "runs all examples in the suite" do
      called = [] of Int32
      group = SpyExample.create_group(5) do |index|
        called << index
        nil
      end
      suite = Spectator::TestSuite.new(group)
      runner = Spectator::Runner.new(suite, spectator_test_config)
      runner.run
      called.should eq([0, 1, 2, 3, 4])
    end

    context "the formatter" do
      it "#start_suite is called once" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.start_suite_call_count.should eq(1)
      end

      it "#start_suite is called at the beginning" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.all_calls.first.should eq(:start_suite)
      end

      it "passes the test suite to #start_suite" do
        test_suite = new_test_suite
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(test_suite, spectator_test_config(spy))
        runner.run
        spy.start_suite_calls.first.should eq(test_suite)
      end

      it "#end_suite is called once" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.end_suite_call_count.should eq(1)
      end

      it "#end_suite is called at the end" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.all_calls.last.should eq(:end_suite)
      end

      it "#start_example is called" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.start_example_call_count.should be > 0
      end

      it "#start_example is called for each example" do
        group = SpyExample.create_group(5) { |index| nil }
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.start_example_call_count.should eq(5)
      end

      it "passes the correct example to #start_example" do
        group = SpyExample.create_group(5) { |index| nil }
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.start_example_calls.should eq(group.children)
      end

      it "calls #end_example" do
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(new_test_suite, spectator_test_config(spy))
        runner.run
        spy.end_example_call_count.should be > 0
      end

      it "calls #end_example for each example" do
        group = SpyExample.create_group(5) { |index| nil }
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.end_example_call_count.should eq(5)
      end

      it "passes the correct result to #end_example" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array.new(5) do |index|
          if index.odd?
            PassingExample.new(group, Spectator::Internals::SampleValues.empty)
          else
            FailingExample.new(group, Spectator::Internals::SampleValues.empty)
          end.as(Spectator::ExampleComponent)
        end
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.end_example_calls.map(&.example).should eq(group.children)
      end
    end

    context "the report" do
      it "contains the expected results" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array.new(5) do |index|
          if index.odd?
            PassingExample.new(group, Spectator::Internals::SampleValues.empty)
          else
            FailingExample.new(group, Spectator::Internals::SampleValues.empty)
          end.as(Spectator::ExampleComponent)
        end
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.end_example_calls.each_with_index do |result, index|
          if index.odd?
            result.should be_a(Spectator::SuccessfulResult)
          else
            result.should be_a(Spectator::FailedResult)
          end
        end
      end

      it "contains the expected time span" do
        group = SpyExample.create_group(5) { |index| nil }
        suite = Spectator::TestSuite.new(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        max_time = Time.measure { runner.run }
        min_time = spy.end_example_calls.each.map(&.as(Spectator::FinishedResult)).sum(&.elapsed)
        report = spy.end_suite_calls.first
        report.runtime.should be <= max_time
        report.runtime.should be >= min_time
      end
    end
  end
end
