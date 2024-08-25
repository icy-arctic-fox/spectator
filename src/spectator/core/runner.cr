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

    def run(spec : ExampleGroup)
      report &.started
      report &.suite_started
      results =
        examples_to_run(spec).map do |example|
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
                 elsif @configuration.dry_run?
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

    private def report(&) : Nil
      @configuration.formatters.each do |formatter|
        yield formatter
      end
    end
  end

  Spectator.sandbox_property current_example : Example?
  Spectator.sandbox_getter root_example_group = ExampleGroup.new
  Spectator.sandbox_getter working_path : Path = Path[Dir.current]
  Spectator.sandbox_getter start_time : Time = Time.local

  def Spectator.elapsed_time : Time::Span
    sandbox.elapsed_time
  end

  class Sandbox
    def with_example(example : Example, &)
      previous_example = @current_example
      begin
        yield
      ensure
        @current_example = previous_example
      end
    end

    @start_monotonic : Time::Span = Time.monotonic

    def elapsed_time : Time::Span
      Time.monotonic - @start_monotonic
    end
  end
end
