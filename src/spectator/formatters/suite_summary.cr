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
      failures = report.failures.map_with_index { |result, index| FailureBlock.new(index + 1, result) }
      puts
      puts
      display_failures(failures) if failures.any?
      display_stats(report)
      display_failure_commands(failures) if failures.any?
    end

    private def display_failures(failures)
      puts "Failures:"
      puts
      failures.each do |block|
        puts block
        puts
      end
    end

    private def display_stats(report)
      puts "Finished in #{human_time(report.runtime)}"
      puts "#{report.example_count} examples, #{report.failed_count} failures, #{report.error_count} errors, #{report.pending_count} pending"
    end

    private def display_failure_commands(failures)
      puts
      puts "Failed examples:"
      puts
      failures.each do |block|
        print "crystal spec "
        block.source(STDOUT)
        puts " # TODO"
      end
    end

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
