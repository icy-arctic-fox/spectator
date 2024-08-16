require "../formatters/summary"
require "./cli"
require "./configuration"
require "./example"
require "./example_group"
require "./sandbox"

module Spectator
  module Core
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
        group.select(Example)
      end

      private def run_example(example : Example) : ExecutionResult
        Spectator.sandbox.with_example(example) do
          report &.example_started(example)
          result = if skip_tag_value = example.skip?
                     skip_message = skip_tag_value.is_a?(Bool) ? "Example Skipped" : skip_tag_value.to_s
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

    class Sandbox
      property current_example : Example?
      getter root_example_group = ExampleGroup.new
      getter path : Path = Path[Dir.current]

      def with_example(example : Example, &)
        previous_example = @current_example
        begin
          yield
        ensure
          @current_example = previous_example
        end
      end

      getter start_time : Time = Time.local

      @start_monotonic : Time::Span = Time.monotonic

      def elapsed_time : Time::Span
        Time.monotonic - @start_monotonic
      end
    end
  end

  def self.root_example_group : Core::ExampleGroup
    sandbox.root_example_group
  end

  def self.current_example : Core::Example
    sandbox.current_example
  end

  protected def self.current_example=(example : Core::Example)
    sandbox.current_example = example
  end

  def self.working_path : Path
    sandbox.path
  end

  def self.start_time : Time
    sandbox.start_time
  end

  def self.elapsed_time : Time::Span
    sandbox.elapsed_time
  end

  class_property? auto_run = true

  def self.run
    Core::CLI.configure
    runner = Core::Runner.new(configuration)
    runner.run(sandbox.root_example_group)
  rescue ex
    STDERR.puts "Spectator encountered an unexpected error."
    ex.inspect_with_backtrace(STDERR)
    exit 1
  end

  at_exit do
    run if auto_run?
  end
end
