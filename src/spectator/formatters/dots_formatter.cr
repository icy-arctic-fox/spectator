require "./common_text_output"
require "./formatter"

module Spectator::Formatters
  class DotsFormatter < Formatter
    include CommonTextOutput

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      case result.status
      in .pass?  then printer.print('.', style: :success)
      in .fail?  then printer.print('F', style: :error)
      in .error? then printer.print('E', style: :error)
      in .skip?  then printer.print('*', style: :warning)
      end
    end

    def started : Nil
    end

    def finished : Nil
    end

    def suite_started : Nil
    end

    def suite_finished : Nil
      puts
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end
  end
end
