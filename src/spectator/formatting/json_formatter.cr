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

    # Begins an example object and adds common fields known before running the example.
    def example_started(notification)
      example = notification.example

      @json.start_object
      @json.field("description", example.name? || "<anonymous>")
      @json.field("full_description", example.to_s)

      if location = example.location?
        @json.field("file_path", location.path)
        @json.field("line_number", location.line)
      end
    end

    # Adds fields to the example object for all result types known after the example completes.
    def example_finished(notification)
      example = notification.example
      result = example.result

      @json.field("run_time", result.elapsed.total_seconds)
      @json.field("expectations") do
        @json.array do
          result.expectations.each(&.to_json(@json))
        end
      end
    end

    # Adds success-specific fields to an example object and closes it.
    def example_passed(_notification)
      @json.field("status", "passed")
      @json.end_object # End example object.
    end

    # Adds pending-specific fields to an example object and closes it.
    def example_pending(_notification)
      @json.field("status", "pending")
      @json.field("pending_message", "Not implemented") # TODO: Fetch pending message from result.
      @json.end_object                                  # End example object.
    end

    # Adds failure-specific fields to an example object and closes it.
    def example_failed(notification)
      example = notification.example
      result = example.result

      @json.field("status", "failed")
      build_exception_object(result.error) if result.responds_to?(:error)
      @json.end_object # End example object.
    end

    # Adds error-specific fields to an example object and closes it.
    def example_error(notification)
      example = notification.example
      result = example.result

      @json.field("status", "error")
      build_exception_object(result.error) if result.responds_to?(:error)
      @json.end_object # End example object.
    end

    # Adds an exception field and object to the JSON document.
    private def build_exception_object(error)
      @json.field("exception") do
        @json.object do
          @json.field("class", error.class.name)
          @json.field("message", error.message)
          @json.field("backtrace", error.backtrace)
        end
      end
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
