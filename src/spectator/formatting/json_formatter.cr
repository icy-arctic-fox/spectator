require "json"
require "./formatter"

module Spectator::Formatting
  # Produces a JSON document with results of the test suite.
  class JSONFormatter < Formatter
    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(io = STDOUT)
      @json = JSON::Builder.new(io)
    end

    # Begins the JSON document output.
    def start(_notification)
      @json.start_document
      @json.start_object
      @json.field("version", Spectator::VERSION)

      # Start examples array.
      @json.string("examples")
      @json.start_array
    end

    # Adds fields to the example object for all result types known after the example completes.
    def example_finished(notification)
      notification.example.to_json(@json)
    end

    # Marks the end of the examples array.
    def stop
      @json.end_array # Close examples array.
    end

    # Adds the profiling information to the document.
    def dump_profile(notification)
      profile = notification.profile

      @json.field("profile") do
        @json.object do
          @json.field("examples") do
            @json.array do
              profile.each(&.to_json(@json))
            end
          end

          @json.field("slowest", profile.max_of(&.result.elapsed).total_seconds)
          @json.field("total", profile.time.total_seconds)
          @json.field("percentage", profile.percentage)
        end
      end
    end

    # Adds the summary object to the document.
    def dump_summary(notification)
      report = notification.report

      @json.field("summary") do
        @json.object do
          @json.field("duration", report.runtime.total_seconds)
          @json.field("example_count", report.counts.total)
          @json.field("failure_count", report.counts.fail)
          @json.field("error_count", report.counts.error)
          @json.field("pending_count", report.counts.pending)
        end
      end

      totals = Components::Totals.new(report.counts)
      @json.field("summary_line", totals.to_s)
    end

    # Ends the JSON document and flushes output.
    def close
      @json.end_object
      @json.end_document
      @json.flush
    end
  end
end
