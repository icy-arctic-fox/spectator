require "../assertion_failed"
require "../core/execution_result"
require "../core/source_cache"

module Spectator::Formatters
  module CommonTextOutput
    private abstract def io : IO

    def report_results(results : Enumerable(Core::ExecutionResult)) : Nil
      failures = results.select &.failed?
      report_failures(failures) unless failures.empty?
      skipped = results.select &.skipped?
      report_skipped(skipped) unless skipped.empty?
    end

    private def report_failures(results : Enumerable(Core::ExecutionResult)) : Nil
      puts
      puts "Failures:"
      puts
      padding = results.size.to_s.size - 1 # -1 since the minimum width is 1.
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
      print_indent(padding)
      print "  #{number}) "
      puts result.example.full_description

      digit_count = number.to_s.size
      indent = padding + digit_count + 4 # +2 for the space and the parenthesis and +2 for the actual indent.
      error = result.exception
      if error.is_a?(AssertionFailed)
        print_indent(indent)
        print "Failure: "
        if location = error.location
          source_code = Spectator.source_cache.get(location.file, location.line)
          puts source_code.strip if source_code
        end
        puts
        print_indent(indent)
        if match_data = error.match_data
          match_data.to_s(io)
        else
          puts error.message
        end
        puts
        if location = error.location
          print_indent(indent)
          # OPTIMIZE: Store current directory to avoid re-fetching it.
          puts "# #{location.relative_to(Dir.current)}"
          puts
        end
      else
        puts
        print_trace(error, indent)
      end
      puts
    end

    private def print_trace(error, indent) : Nil
      print_indent(indent)
      puts "#{error.message} (#{error.class})"

      error.backtrace?.try &.each do |frame|
        print_indent(indent)
        print "  from "
        puts frame
      end

      if cause = error.cause
        print_trace(cause, indent)
      end
    end

    private def report_skipped(results : Enumerable(Core::ExecutionResult)) : Nil
      puts
      puts "Skipped:"
      results.each do |result|
        print "  "
        puts result.example.full_description
      end
      puts
    end

    def report_profile : Nil
    end

    def report_summary : Nil
    end

    private def print_indent(amount) : Nil
      amount.times { print ' ' }
    end
  end
end
