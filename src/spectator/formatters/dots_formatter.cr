require "./common_text_output"
require "./formatter"

module Spectator::Formatters
  class DotsFormatter < Formatter
    include CommonTextOutput

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      case result.status
      in .pass?  then printer.with_style(:success, &.<< '.')
      in .fail?  then printer.with_style(:error, &.<< 'F')
      in .error? then printer.with_style(:error, &.<< 'E')
      in .skip?  then printer.with_style(:warning, &.<< '*')
      end
    end

    def started : Nil
    end

    def finished : Nil
    end

    def suite_started : Nil
    end

    def suite_finished : Nil
      io.puts
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end
  end
end
