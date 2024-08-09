require "../core/example"
require "../core/example_group"
require "../core/execution_result"
require "./summary"

module Spectator::Formatters
  abstract class Formatter
    private getter io : IO

    def initialize(@io = STDOUT)
    end

    abstract def started : Nil

    abstract def finished : Nil

    abstract def suite_started : Nil

    abstract def suite_finished : Nil

    abstract def example_group_started(group : Core::ExampleGroup) : Nil

    abstract def example_group_finished(group : Core::ExampleGroup) : Nil

    abstract def example_started(example : Core::Example) : Nil

    abstract def example_finished(result : Core::ExecutionResult) : Nil

    abstract def report_results(results : Enumerable(Core::ExecutionResult)) : Nil

    abstract def report_profile : Nil

    abstract def report_summary(summary : Summary) : Nil

    delegate print, printf, puts, set_encoding, to: io
  end
end
