require "./spec_helper"

# Creates a `Config` for Spectator that is suited for testing it.
def spectator_test_config(formatter : Spectator::Formatting::Formatter? = nil, fail_fast = false)
  builder = Spectator::ConfigBuilder.new
  builder.formatter = formatter || Spectator::Formatting::SilentFormatter.new
  builder.fail_fast = fail_fast
  builder.build
end

def new_test_suite(group : Spectator::ExampleGroup? = nil)
  filter = Spectator::NullExampleFilter.new
  Spectator::TestSuite.new(group || PassingExample.create.group, filter)
end

def suite_with_nested_failures(hooks)
  conditions = Spectator::ExampleConditions.empty
  values = Spectator::Internals::SampleValues.empty
  root = Spectator::RootExampleGroup.new(hooks, conditions)
  root.children = Array(Spectator::ExampleComponent).new(5) do |index|
    Spectator::NestedExampleGroup.new(index.to_s, root, hooks, conditions).tap do |group|
      group.children = Array(Spectator::ExampleComponent).new(5) { FailingExample.new(group, values) }
    end
  end
  new_test_suite(root)
end

describe Spectator::Runner do
  describe "#run" do
    it "runs all examples in the suite" do
      called = [] of Int32
      group = SpyExample.create_group(5) do |index|
        called << index
        nil
      end
      suite = new_test_suite(group)
      runner = Spectator::Runner.new(suite, spectator_test_config)
      runner.run
      called.should eq([0, 1, 2, 3, 4])
    end

    context "with fail-fast enabled" do
      it "stops on the first failure" do
        called = [] of Int32
        group = SpyExample.create_group(10) do |index|
          called << index
          raise "Failure" if index > 5
        end
        suite = new_test_suite(group)
        runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
        runner.run
        called.should eq([0, 1, 2, 3, 4, 5, 6])
      end

      it "runs after_each hooks" do
        called = false
        hooks = new_hooks(after_each: ->{ called = true; nil })
        group = FailingExample.create_group(hooks: hooks)
        suite = new_test_suite(group)
        runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
        runner.run
        called.should be_true
      end

      it "runs after_all hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        group = FailingExample.create_group(hooks: hooks)
        suite = new_test_suite(group)
        runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
        runner.run
        called.should be_true
      end

      it "runs the remaining around_each hook code" do
        called = false
        hooks = new_hooks(around_each: ->(proc : ->) {
          proc.call
          called = true
          nil
        })
        group = FailingExample.create_group(hooks: hooks)
        suite = new_test_suite(group)
        runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
        runner.run
        called.should be_true
      end

      context "with nested groups" do
        it "runs after_each hooks" do
          call_count = 0
          hooks = new_hooks(after_each: ->{ call_count += 1; nil })
          suite = suite_with_nested_failures(hooks)
          runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
          runner.run
          call_count.should eq(2)
        end

        it "runs after_all hooks" do
          call_count = 0
          hooks = new_hooks(after_all: ->{ call_count += 1; nil })
          suite = suite_with_nested_failures(hooks)
          runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
          runner.run
          call_count.should eq(2)
        end

        it "runs the remaining around_each hook code" do
          call_count = 0
          hooks = new_hooks(around_each: ->(proc : ->) {
            proc.call
            call_count += 1
            nil
          })
          suite = suite_with_nested_failures(hooks)
          runner = Spectator::Runner.new(suite, spectator_test_config(fail_fast: true))
          runner.run
          call_count.should eq(2)
        end
      end

      context "the report" do
        it "has the remaining tests" do
          spy = SpyFormatter.new
          group = SpyExample.create_group(10) do |index|
            raise "Failure" if index > 5
          end
          suite = new_test_suite(group)
          runner = Spectator::Runner.new(suite, spectator_test_config(spy, true))
          runner.run
          args = spy.end_suite_calls.first
          args[:report].remaining_count.should eq(3)
        end
      end
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
        group = SpyExample.create_group(5) { nil }
        suite = new_test_suite(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        spy.start_example_call_count.should eq(5)
      end

      it "passes the correct example to #start_example" do
        group = SpyExample.create_group(5) { nil }
        suite = new_test_suite(group)
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
        group = SpyExample.create_group(5) { nil }
        suite = new_test_suite(group)
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
        suite = new_test_suite(group)
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
        suite = new_test_suite(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        runner.run
        args = spy.end_suite_calls.first
        args[:report].each_with_index do |result, index|
          if index.odd?
            result.should be_a(Spectator::SuccessfulResult)
          else
            result.should be_a(Spectator::FailedResult)
          end
        end
      end

      it "contains the expected time span" do
        group = SpyExample.create_group(5) { nil }
        suite = new_test_suite(group)
        spy = SpyFormatter.new
        runner = Spectator::Runner.new(suite, spectator_test_config(spy))
        max_time = Time.measure { runner.run }
        min_time = spy.end_example_calls.each.map(&.as(Spectator::FinishedResult)).sum(&.elapsed)
        args = spy.end_suite_calls.first
        report = args[:report]
        report.runtime.should be <= max_time
        report.runtime.should be >= min_time
      end
    end
  end
end
