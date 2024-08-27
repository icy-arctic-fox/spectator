require "../formatters/summary"
require "./cli"
require "./configuration"
require "./example"
require "./example_group"
require "./sandbox"

module Spectator::Core
  class Runner
    def initialize(@configuration : Configuration)
    end

    def run(spec : ExampleGroup) : Bool
      examples = examples_to_run(spec)
      if @configuration.mode.list_tags?
        print_tags(examples)
        return true
      end

      report &.started
      report &.suite_started
      results =
        examples.map do |example|
          if (group = example.group) && group.no_runs?
            report &.example_group_started(group)
          end
          result = run_example(example)
          if (group = example.group) && group.run?
            report &.example_group_finished(group)
          end
          result
        end
      report &.suite_finished
      report &.report_results(results)
      report &.report_profile
      summary = Formatters::Summary.from_results(results.map &.result, Spectator.elapsed_time)
      report &.report_summary(summary)
      report &.finished

      results.none? &.failed?
    end

    private def examples_to_run(group : ExampleGroup) : Array(Example)
      examples = group.select(Example)
      if filter = @configuration.inclusion_filter
        examples.select! { |example| filter.matches?(example) }
      end
      if filter = @configuration.exclusion_filter
        examples.reject! { |example| filter.matches?(example) }
      end
      examples
    end

    private def run_example(example : Example) : ExecutionResult
      Spectator.sandbox.with_example(example) do
        report &.example_started(example)
        result = if skip_tag_value = example.skip?
                   skip_message = skip_tag_value.to_s unless skip_tag_value.is_a?(Bool)
                   error = ExampleSkipped.new(skip_message, example.location)
                   Result.new(:skip, Time::Span.zero, error)
                 elsif @configuration.mode.dry_run?
                   Result.new(:pass, Time::Span.zero)
                 else
                   example.run
                 end
        result = ExecutionResult.new(example, result)
        report &.example_finished(result)
        Fiber.yield
        result
      end
    end

    private def print_tags(examples : Enumerable(Example)) : Nil
      tally = Hash(String, Int32).new(0)
      examples.each do |example|
        tags = example.all_tags
        if tags.empty?
          tally.update("untagged", &.+ 1)
        else
          tags.each_key do |tag|
            tally.update(tag, &.+ 1)
          end
        end
      end

      longest_tag_length = tally.each_key.max_of &.size
      tally.each do |tag, count|
        tag.rjust(STDOUT, longest_tag_length)
        print ": ", count
        puts
      end
    end

    private def report(&) : Nil
      @configuration.formatters.each do |formatter|
        yield formatter
      end
    end
  end

  # Current running example.
  # Returns `nil` if no example is running.
  Spectator.sandbox_property current_example : Example?

  # The root example group.
  # Everything contained in this group (and children) is run.
  Spectator.sandbox_getter root_example_group = ExampleGroup.new

  # The current working path.
  # This is the directory that the application starts in.
  # All relative file and directory paths are relative to this.
  Spectator.sandbox_getter working_path : Path = Path[Dir.current]

  # The date and time the application started.
  # For sandboxes, this is the time at which the sandbox was created.
  Spectator.sandbox_getter start_time : Time = Time.local

  # Filter used to include examples to run.
  # Examples not matching the filter will not be run.
  Spectator.config_property inclusion_filter : Filter?

  # Filter used to exclude examples from running.
  # Examples matching the filter will not be run.
  # Excluded examples take precedence over included examples.
  # That is, if an example matches both filters, it will not be run.
  Spectator.config_property exclusion_filter : Filter?

  # The mode in which the application will run.
  enum Mode
    # Run all examples and report results.
    Normal

    # Report all examples as passed without running them.
    DryRun

    # Produce a list of tags used in the examples without running them.
    ListTags
  end

  # Specifies the mode in which the application will run.
  # The default is to run all examples and report results.
  Spectator.config_property mode = Mode::Normal

  # Specifies that the application should exit after the number of failures.
  Spectator.config_numeric_property fail_fast = 0, truthy: 1

  # When true, the test suite will fail if it contains no examples.
  Spectator.config_property? fail_if_no_examples = true

  # The number of examples that should be profiled.
  # When enabled, the slowest examples to complete will be included in the output.
  Spectator.config_numeric_property profile_examples = 0, truthy: 10

  # The seed used to initialize the Crystal's default random number generator.
  Spectator.config_property seed : UInt64?

  # The order in which examples are run.
  enum Order
    # Examples run in the order they are defined in source code.
    Defined

    # Examples run in a random order.
    # The order is determined by the seed value.
    Random

    # Recently modified examples are run first.
    Modified
  end

  # The order in which examples are run.
  Spectator.config_property order = Order::Defined

  # The elapsed time since the application started.
  # For sandboxes, this is the time elapsed since the sandbox was created.
  def Spectator.elapsed_time : Time::Span
    sandbox.elapsed_time
  end

  class Sandbox
    # Updates the current example.
    # The `#current_example` property is set for the duration of the block.
    # The previous example (if there was one) is restored when the block exits.
    def with_example(example : Example, &)
      previous_example = @current_example
      begin
        yield
      ensure
        @current_example = previous_example
      end
    end

    @start_monotonic : Time::Span = Time.monotonic

    # Elapsed time since the sandbox was created.
    def elapsed_time : Time::Span
      Time.monotonic - @start_monotonic
    end
  end
end
