require "./formatter"
require "colorize"

module Spectator::Formatters
  class DefaultFormatter < Formatter
    SUCCESS_COLOR = :green
    FAILURE_COLOR = :red
    ERROR_COLOR   = :magenta
    PENDING_COLOR = :yellow

    SUCCESS_CHAR = '.'.colorize(SUCCESS_COLOR)
    FAILURE_CHAR = 'F'.colorize(FAILURE_COLOR)
    ERROR_CHAR   = 'E'.colorize(ERROR_COLOR)
    PENDING_CHAR = '*'.colorize(PENDING_COLOR)

    def start_suite(suite : TestSuite)
    end

    def end_suite(report : Report)
      puts
      puts
      display_failures(report)
      display_errors(report)
      display_summary(report)
    end

    private def display_failures(report)
      failures = report.failures
      if failures.any?
        puts "Failures:"
        puts
        failures.each_with_index do |failure, index|
          display_failure(failure.as(FailedResult), index + 1)
        end
      end
    end

    private def display_failure(failure, number)
      expected = "TODO"
      actual = "TODO"
      puts "  #{number}) #{failure.example}"
      puts "     Failure: #{failure.error.message}"
      puts
      puts "       Expected: #{expected}"
      puts "            got: #{actual}"
      puts
    end

    private def display_errors(report)
    end

    private def display_summary(report)
      puts finish_time_string(report)
      puts result_string(report)
    end

    def start_example(example : Example)
    end

    def end_example(result : Result)
      print result_char(result)
    end

    private def result_char(result : Result)
      case result
      when SuccessfulResult
        SUCCESS_CHAR
      when PendingResult
        PENDING_CHAR
      when ErroredResult
        ERROR_CHAR
      when FailedResult
        FAILURE_CHAR
      end
    end

    private def finish_time_string(report)
      "Finished in #{human_time(report.runtime)}"
    end

    private def result_string(report)
      examples = report.examples
      failures = report.failed_examples
      errors = report.errored_examples
      pending = report.pending_examples
      string = "#{examples} examples, #{failures} failures, #{errors} errors, #{pending} pending"
      if failures > 0 || errors > 0
        string.colorize(FAILURE_COLOR)
      elsif pending != examples
        string.colorize(PENDING_COLOR)
      else
        string.colorize(SUCCESS_COLOR)
      end
    end

    private def human_time(span : Time::Span)
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
