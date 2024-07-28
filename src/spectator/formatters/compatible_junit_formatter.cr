require "./formatter"
require "./junit/*"

module Spectator::Formatters
  # JUnit formatter that matches the JUnit output produced by the Spec framework.
  # Some utilities, such as Crystal plugin for VS code, expect the the output produced by Spec.
  class CompatibleJUnitFormatter < Formatter
    @test_cases = [] of JUnit::TestCase
    @failure_count = 0
    @error_count = 0
    @skipped_count = 0
    @elapsed_time = Time::Span.zero

    def initialize(@output : IO, *, @close_output : Bool = false)
    end

    def self.file(output_path : String) : self
      path = Path[output_path]
      if path.extension != ".xml"
        path /= "output.xml"
      end

      Dir.mkdir_p(path.dirname)
      file = File.new(path, "w")
      new(file, close_output: true)
    end

    def started : Nil
      set_encoding("UTF-8")
      puts %(<?xml version="1.0" encoding="UTF-8"?>)
    end

    def finished : Nil
      @test_cases.clear

      @failure_count = 0
      @error_count = 0
      @skipped_count = 0
      @elapsed_time = Time::Span.zero

      @output.close if @close_output
    end

    def suite_started : Nil
    end

    def suite_finished : Nil
      JUnit::TestSuite.new(
        tests: @test_cases.size,
        failures: @failure_count,
        errors: @error_count,
        skipped: @skipped_count,
        time: @elapsed_time, # TODO: Should be total time, not just the time spent in tests.
        timestamp: Time.utc, # TODO: Should be start time.
        hostname: System.hostname,
        test_cases: @test_cases,
      ).to_xml(@output)
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      location = result.example.location
      class_name = construct_class_name(location)

      properties = {
        name:       result.example.full_description || "<Anonymous>",
        class_name: class_name,
        file:       location.try &.file,
        line:       location.try &.line,
      }

      @test_cases << if result.failed?
        JUnit::FailedTestCase.new(**properties, error: result.exception)
      elsif result.skipped?
        JUnit::SkippedTestCase.new(**properties, skip_message: result.error_message)
      else
        JUnit::PassedTestCase.new(**properties)
      end

      @failure_count += 1 if result.failed?
      @skipped_count += 1 if result.skipped?
      @error_count += 1 if result.error?
      @elapsed_time += result.elapsed
    end

    private def construct_class_name(location) : String
      return "spec" unless location

      relative_location = location.relative_to(Spectator.working_path)
      parts = Path[relative_location.file].parts
      file_part = parts[-1]
      parts[-1] = file_part.rchop(File.extname(file_part))
      parts.join('.')
    end

    def report_results(results : Enumerable(Core::ExecutionResult)) : Nil
    end

    def report_profile : Nil
    end

    def report_summary : Nil
    end
  end
end
