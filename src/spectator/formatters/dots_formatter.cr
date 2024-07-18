require "./common_text_output"
require "./formatter"

module Spectator::Formatters
  class DotsFormatter < Formatter
    include CommonTextOutput

    PASS_CHAR  = '.'
    FAIL_CHAR  = 'F'
    ERROR_CHAR = 'E'
    SKIP_CHAR  = '*'

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      print case result.status
      in .pass?  then PASS_CHAR
      in .fail?  then FAIL_CHAR
      in .error? then ERROR_CHAR
      in .skip?  then SKIP_CHAR
      end
    end

    def started : Nil
    end

    def finished : Nil
    end

    def suite_started : Nil
    end

    def suite_finished : Nil
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end
  end
end
