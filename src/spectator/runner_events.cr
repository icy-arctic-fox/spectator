require "./formatting/formatter"
require "./formatting/notifications"

module Spectator
  # Mix-in for announcing events from a `Runner`.
  # All events invoke their corresponding method on the formatter.
  module RunnerEvents
    # Triggers the 'start' event.
    # See `Formatting::Formatter#start`
    private def start
      notification = Formatting::StartNotification.new(example_count)
      formatter.start(notification)
    end

    # Triggers the 'example started' event.
    # Must be passed the *example* about to run.
    # See `Formatting::Formatter#example_started`
    private def example_started(example)
      notification = Formatting::ExampleNotification.new(example)
      formatter.example_started(notification)
    end

    # Triggers the 'example started' event.
    # Also triggers the example result event corresponding to the example's outcome.
    # Must be passed the completed *example*.
    # See `Formatting::Formatter#example_finished`
    private def example_finished(example)
      notification = Formatting::ExampleNotification.new(example)
      visitor = ResultVisitor.new(formatter, notification)
      formatter.example_finished(notification)
      example.result.accept(visitor)
    end

    # Triggers the 'stop' event.
    # See `Formatting::Formatter#stop`
    private def stop
      formatter.stop
    end

    # Triggers the 'dump' events.
    private def summarize(report, profile)
      formatter.start_dump

      notification = Formatting::ExampleSummaryNotification.new(report.pending)
      formatter.dump_pending(notification)

      notification = Formatting::ExampleSummaryNotification.new(report.failures)
      formatter.dump_failures(notification)

      if profile
        notification = Formatting::ProfileNotification.new(profile)
        formatter.dump_profile(notification)
      end

      notification = Formatting::SummaryNotification.new(report)
      formatter.dump_summary(notification)
    end

    # Triggers the 'close' event.
    # See `Formatting::Formatter#close`
    private def close
      formatter.close
    end

    # Provides methods for the various result types.
    private struct ResultVisitor
      # Creates the visitor.
      # Requires the *formatter* to notify and the *notification* to send it.
      def initialize(@formatter : Formatting::Formatter, @notification : Formatting::ExampleNotification)
      end

      # Invokes the example passed method.
      def pass(_result)
        @formatter.example_passed(@notification)
      end

      # Invokes the example failed method.
      def fail(_result)
        @formatter.example_failed(@notification)
      end

      # Invokes the example error method.
      def error(_result)
        @formatter.example_error(@notification)
      end

      # Invokes the example pending method.
      def pending(_result)
        @formatter.example_pending(@notification)
      end
    end
  end
end
