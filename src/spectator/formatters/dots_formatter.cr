require "./formatter"

module Spectator::Formatters
  class DotsFormatter < Formatter
    PASS_CHAR  = '.'
    FAIL_CHAR  = 'F'
    ERROR_CHAR = 'E'
    SKIP_CHAR  = '*'

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(example : Core::Example, result : Core::Result) : Nil
      print case result.status
      in .pass?  then PASS_CHAR
      in .fail?  then FAIL_CHAR
      in .error? then ERROR_CHAR
      in .skip?  then SKIP_CHAR
      end
    end
  end
end
