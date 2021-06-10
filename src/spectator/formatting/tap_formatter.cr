require "./formatter"

module Spectator::Formatting
  # Produces TAP output from test results.
  # See: https://testanything.org/
  # Version 12 of the specification is used.
  class TAPFormatter < Formatter
    @counter = 0

    # Creates the formatter.
    def initialize(@io : IO = STDOUT)
    end

    # Invoked when the test suite begins.
    def start(notification)
      @io << "1.."
      @io.puts notification.example_count
    end

    # Invoked just after an example completes.
    def example_finished(_notification)
      @counter += 1
    end

    # Invoked after an example completes successfully.
    def example_passed(notification)
      @io << "ok " << @counter << " - "
      @io.puts notification.example
    end

    # Invoked after an example is skipped or marked as pending.
    def example_pending(notification)
      # TODO: Skipped tests should report ok.
      @io << "not ok " << @counter << " - "
      @io << notification.example << " # TODO "

      # This should never be false.
      if (result = notification.example.result).responds_to?(:reason)
        @io.puts result.reason
      end
    end

    # Invoked after an example fails.
    def example_failed(notification)
      @io << "not ok " << @counter << " - "
      @io.puts notification.example
    end

    # Invoked after an example fails from an unexpected error.
    def example_error(notification)
      example_failed(notification)
    end

    # Called whenever the example or framework produces a message.
    # This is typically used for logging.
    def message(notification)
      @io << "# "
      @io.puts notification.message
    end

    # Invoked after testing completes with profiling information.
    def dump_profile(notification)
      @io << Components::TAPProfile.new(notification.profile)
    end

    # Invoked after testing completes with summarized information from the test suite.
    def dump_summary(notification)
      @io.puts "Bail out!" if notification.report.counts.remaining?
    end
  end
end
