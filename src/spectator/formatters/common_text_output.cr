require "../assertion_failed"
require "../core/execution_result"
require "../core/source_cache"
require "./terminal_printer"

module Spectator::Formatters
  module CommonTextOutput
    private abstract def io : IO

    private getter printer do
      TerminalPrinter.new(io)
    end

    def report_results(results : Enumerable(Core::ExecutionResult)) : Nil
      printer.puts
      failures = results.select &.failed?
      report_failures(failures) unless failures.empty?
      skipped = results.select &.skipped?
      report_skipped(skipped) unless skipped.empty?
    end

    private def report_failures(results : Enumerable(Core::ExecutionResult)) : Nil
      printer.print_title(:error, &.<< "Failures:")
      printer.puts
      padding = results.size.to_s.size + 1
      results.each_with_index(1) do |result, index|
        print_failure(result, index, padding)
      end
    end

    # Produces a block of text that looks like this for failures:
    #
    # ```text
    # 1) Full example description
    #    Failure: <SOURCE CODE>
    #
    #    Expected: "foo"
    #         got: "bar"
    #
    #    # spec/example_spec.cr:42
    # ```
    #
    # and like this for errors:
    #
    # ```text
    # 1) Full example description
    #
    #    Error message (RuntimeError)
    #      <STACK TRACE>
    #
    #    # spec/example_spec.cr:42
    # ```
    private def print_failure(result, number, padding) : Nil
      digit_count = number.to_s.size
      padding -= digit_count
      printer.print_inline_label("#{number})", padding: padding) do
        printer.puts result.example.full_description, style: :error

        error = result.exception
        if error.is_a?(AssertionFailed)
          printer.print_label(:error, &.<< "Failure: ")
          if location = error.location
            if source_code = Spectator.source_cache.get(location.file, location.line, location.end_line)
              if location.line == location.end_line
                printer.print_code(source_code.strip)
              else
                printer.puts
                printer.indent &.print_code(source_code)
              end
            end
          end
          printer.puts
          if match_data = error.match_data
            match_data.format(printer)
            printer.puts
          else
            printer.puts error.message
          end
          printer.puts
          if location = error.location
            relative_path = location.relative_to(Spectator.working_path)
            printer.puts "# #{relative_path}", style: :info
            printer.puts
          end
        else
          print_trace(error)
        end
      end
    end

    private def print_trace(error) : Nil
      printer.print_label(:error, &.<< "#{error.class}: ")
      printer.puts "#{error.message}"

      printer.indent do
        error.backtrace?.try &.each do |frame|
          frame = frame.colorize.dim if external_frame?(frame)
          printer.puts frame
        end
      end
      printer.puts

      if cause = error.cause
        print_trace(cause)
      end
    end

    private def external_frame?(frame : String)
      frame.starts_with?("lib/") ||    # Crystal shards
        frame.starts_with?('/') ||     # POSIX absolute path
        frame.starts_with?(/^\w+:/) || # Windows absolute path
        frame == "???"
    end

    private def report_skipped(results : Enumerable(Core::ExecutionResult)) : Nil
      printer.print_title(:warning, &.<< "Skipped:")
      printer.puts
      printer.indent do
        results.each do |result|
          printer.puts result.example.full_description
        end
      end
      printer.puts
    end

    def report_profile : Nil
    end

    def report_summary : Nil
    end
  end
end
