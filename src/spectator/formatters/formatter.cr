require "../core/example"
require "../core/example_group"
require "../core/execution_result"

module Spectator::Formatters
  abstract class Formatter
    def initialize(@output = STDOUT)
    end

    abstract def started : Nil

    abstract def finished : Nil

    abstract def suite_started : Nil

    abstract def suite_finished : Nil

    abstract def example_group_started(group : Core::ExampleGroup) : Nil

    abstract def example_group_finished(group : Core::ExampleGroup) : Nil

    abstract def example_started(example : Core::Example) : Nil

    abstract def example_finished(result : Core::ExecutionResult) : Nil

    abstract def report_failures(results : Enumerable(Core::ExecutionResult)) : Nil

    abstract def report_pending(results : Enumerable(Core::ExecutionResult)) : Nil

    abstract def report_profile : Nil

    abstract def report_summary : Nil

    abstract def report_post_summary : Nil

    delegate print, printf, puts, to: @output
  end
end
