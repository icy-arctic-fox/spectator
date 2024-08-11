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
      printer.with_style(:error, &.title "Failures:")
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
      printer.label("#{number})", padding: padding) do
        printer.with_style(:error, &.puts result.example.full_description)

        error = result.exception
        if error.is_a?(AssertionFailed)
          printer.with_style(:error, &.<< "Failure: ")
          if location = error.location
            if source_code = Spectator.source_cache.get(location.file, location.line, location.end_line)
              if location.line == location.end_line
                printer.code(source_code.strip)
              else
                printer.puts
                printer.indent do
                  printer.code(source_code.chomp)
                end
              end
            end
          end
          printer.puts
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
            printer.with_style(:info, &.print "# ", relative_path)
            printer.puts
            printer.puts
          end
        else
          print_trace(error)
        end
      end
    end

    private def print_trace(error) : Nil
      printer.with_style(:error, &.print error.class, ": ")
      printer.puts error.message

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
      printer.with_style(:warning, &.title "Skipped:")
      printer.indent do
        results.each do |result|
          printer.puts result.example.full_description
        end
      end
      printer.puts
    end

    def report_profile : Nil
    end

    def report_summary(summary : Summary) : Nil
      status = case summary
               when .passed?  then "Passed"
               when .errored? then "Failed (with errors)"
               when .failed?  then "Failed"
               when .skipped? then "Passed (with skipped examples)"
               else                "Finished"
               end
      printer.with_style(summary.title_style, &.title status)
      printer << "Finished after " << humanize(summary.total_time)
      printer << " (" << humanize(summary.test_time) << " in tests)"
      printer.puts

      printer.with_style(summary.style) do
        printer << summary.total << " examples, "
        printer << summary.failed << " failures"
        if summary.errors > 0
          printer << " (" << summary.errors << " errors)"
        end
        if summary.skipped > 0
          printer << ", " << summary.skipped << " skipped"
        end
      end
      printer.puts
    end

    # TODO: Move to a utility module.
    private def humanize(span : Time::Span) : Nil
      if span < 1.millisecond
        printer << span.total_microseconds.round << " microseconds"
      elsif span < 1.second
        printer << span.total_milliseconds.round(2) << " milliseconds"
      elsif span < 1.minute
        printer << span.total_seconds.round(2) << " seconds"
      else
        printer << span.to_i.seconds
      end
    end
  end
end
