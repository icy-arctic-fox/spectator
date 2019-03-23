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
  end
end

module Spectator
  abstract class Example < ExampleComponent
    def to_json(json : ::JSON::Builder)
      json.string(to_s)
    end
  end

  struct Source
    def to_json(json : ::JSON::Builder)
      json.string(to_s)
    end
  end

  module Expectations
    class ExampleExpectations
      def to_json(json : ::JSON::Builder)
        json.array do
          each &.to_json(json)
        end
      end
    end

    class Expectation
      def to_json(json : ::JSON::Builder)
        json.object do
          json.field("satisfied") { satisfied?.to_json(json) }
          json.field("expected") { expected_message.to_json(json) }
          json.field("actual") { actual_message.to_json(json) }
          json.field("values") do
            json.object do
              values.each do |labeled_value|
                json.field(labeled_value.label, labeled_value.value.to_s)
              end
            end
          end
        end
      end
    end
  end
end
