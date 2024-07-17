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
      puts "Starting..."
    end

    def finished : Nil
      puts "Finished."
    end

    def suite_started : Nil
      puts "Starting suite..."
    end

    def suite_finished : Nil
      puts "Finished suite."
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
      puts "Starting #{group.full_description}..."
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
      puts "Finished #{group.full_description}."
    end
  end
end
