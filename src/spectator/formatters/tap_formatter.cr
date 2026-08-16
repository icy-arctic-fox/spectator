require "./formatter"

module Spectator::Formatters
  class TAPFormatter < Formatter
    @id = 0

    private getter printer do
      TerminalPrinter.new(io)
    end

    def started : Nil
    end

    def finished : Nil
    end

    def suite_started : Nil
      @id = 0
    end

    def suite_finished : Nil
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end

    def example_started(example : Core::Example) : Nil
      @id += 1
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      status = case result.status
               when .pass?, .skip?  then "ok "
               when .fail?, .error? then "not ok "
               end
      printer << status << @id
      if result.skipped?
        printer << " # skip"
        if message = result.exception.message
          printer << ' ' << message
        end
      end
      description = result.example.full_description.try &.gsub('#', "\\#")
      printer << " - " << description if description
      printer.puts
    end

    def report_results(results : Enumerable(Core::ExecutionResult)) : Nil
      printer << 1 << ".." << @id
      printer.puts
    end

    def report_profile(profile : Profile) : Nil
    end

    def report_summary(summary : Summary) : Nil
    end
  end
end
