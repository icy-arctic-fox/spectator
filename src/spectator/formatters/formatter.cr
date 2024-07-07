module Spectator::Formatters
  abstract class Formatter
    def initialize(@output = STDOUT)
    end

    abstract def example_started(example : Core::Example) : Nil

    abstract def example_finished(example : Core::Example, result : Core::Result) : Nil

    delegate print, printf, puts, to: @output
  end
end
