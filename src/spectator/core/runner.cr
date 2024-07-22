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
        failures = [] of ExecutionResult
        pending = [] of ExecutionResult
        examples_to_run(spec).each do |example|
          if (group = example.group) && group.no_runs?
            report &.example_group_started(group)
          end
          result = run_example(example)
          if result.failed?
            failures << result
          elsif result.skipped?
            pending << result
          end
          if (group = example.group) && group.run?
            report &.example_group_finished(group)
          end
        end
        report &.suite_finished
        report &.report_failures(failures) unless failures.empty?
        report &.report_pending(pending) unless pending.empty?
        report &.report_profile
        report &.report_summary
        report &.report_post_summary
        report &.finished
      end

      private def examples_to_run(group : ExampleGroup) : Array(Example)
        group.select(Example)
      end

      private def run_example(example : Example) : ExecutionResult
        Spectator.sandbox.with_example(example) do
          report &.example_started(example)
          result = if @configuration.dry_run?
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
      property! current_example : Example
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
    end
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
