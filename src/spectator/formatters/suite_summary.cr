module Spectator::Formatters
  # Mix-in for producing a human-readable summary of a test suite.
  module SuiteSummary
    # Does nothing when starting a test suite.
    def start_suite(suite)
      # ...
    end

    # Produces the summary of test suite from a report.
    # A block describing each failure is displayed.
    # At the end, the totals and runtime are printed.
    def end_suite(report)
      failed = report.failed_count > 0
      @io.puts
      @io.puts
      failures(report.failures) if failed
      stats(report)
      failure_commands(report.failures) if failed
    end

    # Produces the failure section of the summary.
    # This has a "Failures" title followed by a block for each failure.
    private def failures(failures)
      @io.puts "Failures:"
      @io.puts
      failures.each_with_index do |result, index|
        @io.puts FailureBlock.new(index + 1, result)
        @io.puts
      end
    end

    # Produces the statistical section of the summary.
    # This contains how long the suite took to run
    # and the counts for the results (total, failures, errors, and pending).
    private def stats(report)
      @io.puts "Finished in #{human_time(report.runtime)}"
      @io.puts "#{report.example_count} examples, #{report.failed_count} failures, #{report.error_count} errors, #{report.pending_count} pending"
    end

    # Produces the failure commands section of the summary.
    # This provides a set of commands the user can run
    # to test just the examples that failed.
    private def failure_commands(failures)
      @io.puts
      @io.puts "Failed examples:"
      @io.puts
      failures.each do |result|
        @io.print "crystal spec "
        result.example.source.to_s(@io)
        @io << ' '
        @io.puts Comment.color("TODO")
      end
    end

    # Provides a more human-friendly formatting for a time span.
    private def human_time(span)
      millis = span.total_milliseconds
      return "#{(millis * 1000).round.to_i} microseconds" if millis < 1

      seconds = span.total_seconds
      return "#{millis.round(2)} milliseconds" if seconds < 1
      return "#{seconds.round(2)} seconds" if seconds < 60

      int_seconds = seconds.to_i
      minutes = int_seconds / 60
      int_seconds %= 60
      return sprintf("%i:%02i", minutes, int_seconds) if minutes < 60

      hours = minutes / 60
      minutes %= 60
      return sprintf("%i:%02i:%02i", hours, minutes, int_seconds) if hours < 24

      days = hours / 24
      hours %= 24
      return sprintf("%i days %i:%02i:%02i", days, hours, minutes, int_seconds)
    end
  end
end
