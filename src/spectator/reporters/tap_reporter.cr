require "./reporter"

module Spectator::Reporters
  class TAPReporter
    include Reporter

    @example_number = 0

    def initialize(@output = STDOUT)
    end

    def example_started(example : Core::Example) : Nil
      @example_number += 1
    end

    def example_finished(example : Core::Example, result : Core::Result) : Nil
      if result.pass?
        @output << "ok "
      else
        @output << "not ok "
      end
      @output << @example_number
      if example.description?
        @output << " - "
        example.full_description(@output)
      end
      @output.puts
    end
  end
end
