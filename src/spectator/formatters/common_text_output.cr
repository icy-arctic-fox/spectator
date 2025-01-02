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
          if match_failure = error.match_failure
            match_failure.format(printer)
            printer.puts
          else
            printer.puts error.message
          end
          printer.puts
          printer.puts if print_location(error)
        else
          print_trace(error)
        end
      end
    end

    private def print_trace(error) : Nil
      printer.with_style(:error, &.print error.class, ": ")
      printer.puts error.message

      printer.indent do
        if backtrace = error.backtrace?
          # TODO: Allow customizing the collapse threshold.
          collapse_backtrace(backtrace) do |is_external, frame|
            frame ||= "--- omitted ---" # Collapsed frame
            frame = frame.colorize.dim if is_external
            printer.puts frame
          end
        end
      end
      printer.puts

      if cause = error.cause
        print_trace(cause)
      end
    end

    private def collapse_backtrace(backtrace : Iterable(String), & : Bool, String? -> _) : Nil
      # Enumerate through the backtrace and collapse multiple consecutive external frames.
      # For example, if the backtrace is:
      #
      # ```text
      # spec/example_spec.cr:42:in `example'
      # lib/spectator.cr:1:in `example'
      # lib/spectator.cr:2:in `example' # This frame ...
      # lib/spectator.cr:3:in `example' # and this frame should be omitted.
      # lib/spectator.cr:4:in `example'
      # spec/example_spec.cr:42:in `example'
      # ```
      #
      # Then the collapsed backtrace is:
      #
      # ```text
      # spec/example_spec.cr:42:in `example'
      # lib/spectator.cr:1:in `example'
      # --- omitted ---
      # lib/spectator.cr:4:in `example'
      # spec/example_spec.cr:42:in `example'
      # ```

      chunks = backtrace.chunk(true) { |frame| external_frame?(frame) }
      chunks.each do |is_external, frames|
        if is_external && frames.size > 2
          yield is_external, frames[0]
          yield is_external, nil
          yield is_external, frames[-1]
        else
          frames.each { |frame| yield is_external, frame }
        end
      end
    end

    private def external_frame?(frame : String)
      Path[frame].absolute? ||
        frame.starts_with?("lib/") || # Crystal shards
        frame == "???"
    end

    private def report_skipped(results : Enumerable(Core::ExecutionResult)) : Nil
      printer.with_style(:warning, &.title "Skipped:")
      printer.indent do
        results.each do |result|
          printer.with_style(:warning, &.puts result.example.full_description)
          next unless skip_message = result.error_message
          printer.indent do
            print_location(result.example)
            printer.puts skip_message
          end
        end
      end
      printer.puts
    end

    private def print_location(locatable)
      if location = locatable.location
        printer.with_style(:info, &.print "@ ", location.relative_to(Spectator.working_path))
        printer.puts
        true
      end
    end

    def report_profile : Nil
    end

    def report_summary(summary : Summary) : Nil
      printer.with_style(summary.title_style, &.title summary.text)
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
