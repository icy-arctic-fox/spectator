require "./formatter"

module Spectator::Formatters
  class TAPFormatter
    @example_number = 0

    def example_started(example : Core::Example) : Nil
      @example_number += 1
    end

    def example_finished(example : Core::Example, result : Core::Result) : Nil
      if result.pass?
        print "ok "
      else
        print "not ok "
      end
      print @example_number
      if example.description?
        print " - "
        example.full_description(@output)
      end
      puts
    end
  end
end
