require "./common_text_output"
require "./formatter"

module Spectator::Formatters
  class DotsFormatter < Formatter
    include CommonTextOutput

    PASS_CHAR  = '.'
    FAIL_CHAR  = 'F'
    ERROR_CHAR = 'E'
    SKIP_CHAR  = '*'

    PASS_STYLE  = Style::Success
    FAIL_STYLE  = Style::Error
    ERROR_STYLE = Style::Error
    SKIP_STYLE  = Style::Warning

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      case result.status
      in .pass?  then printer.print PASS_CHAR, style: PASS_STYLE
      in .fail?  then printer.print FAIL_CHAR, style: FAIL_STYLE
      in .error? then printer.print ERROR_CHAR, style: ERROR_STYLE
      in .skip?  then printer.print SKIP_CHAR, style: SKIP_STYLE
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
