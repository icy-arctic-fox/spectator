require "json"
require "./formatter"

module Spectator::Formatting
  # Produces a JSON document containing the test results.
  class JsonFormatter < Formatter
    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(io : IO = STDOUT)
      @json = ::JSON::Builder.new(io)
    end

    # Called when a test suite is starting to execute.
    def start_suite(suite : TestSuite)
      @json.start_document
      @json.start_object
      @json.string("examples")
      @json.start_array
    end

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    def end_suite(report : Report)
      @json.end_array # examples
      totals(report)
      timing(report)
      @json.field("result", report.failed? ? "fail" : "success")
      @json.end_object
    end

    # Called before a test starts.
    def start_example(example : Example)
    end

    # Called when a test finishes.
    # The result of the test is provided.
    def end_example(result : Result)
      result.to_json(@json)
    end

    # Adds the totals section of the document.
    private def totals(report)
      @json.field("totals") do
        @json.object do
          @json.field("examples", report.example_count)
          @json.field("success", report.successful_count)
          @json.field("fail", report.failed_count)
          @json.field("error", report.error_count)
          @json.field("pending", report.pending_count)
          @json.field("remaining", report.remaining_count)
        end
      end
    end

    # Adds the timings section of the document.
    private def timing(report)
      @json.field("timing") do
        @json.object do
          @json.field("runtime", report.runtime.to_s)
          @json.field("examples", report.example_runtime.to_s)
          @json.field("overhead", report.overhead_time.to_s)
        end
      end
    end
  end
end