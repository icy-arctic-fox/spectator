require "./reporter"

module Spectator::Reporters
  class DotsReporter
    include Reporter

    PASS_CHAR  = '.'
    FAIL_CHAR  = 'F'
    ERROR_CHAR = 'E'
    SKIP_CHAR  = '*'

    def initialize(@output = STDOUT)
    end

    def example_finished(example : Core::Example, result : Core::Result) : Nil
      case result.status
      in .pass?  then @output << PASS_CHAR
      in .fail?  then @output << FAIL_CHAR
      in .error? then @output << ERROR_CHAR
      in .skip?  then @output << SKIP_CHAR
      end
    end
  end
end
