require "./formatter"
require "./junit/*"

module Spectator::Formatters
  class JUnitFormatter < Formatter
    @test_cases = [] of JUnit::TestCase
    @close_on_finish = false

    def initialize(@output : IO)
    end

    def initialize(output_path : String)
      path = Path[output_path]

      if path.extension != ".xml"
        path = path.join("output.xml")
      end

      Dir.mkdir_p(path.dirname)
      @output = File.new(path, "w")
      @close_on_finish = true
    end

    def started : Nil
      set_encoding("UTF-8")
      puts %(<?xml version="1.0" encoding="UTF-8"?>)
    end

    def finished : Nil
      @test_cases.clear
      @output.close if @close_on_finish
    end

    def suite_started : Nil
      # TODO: The `testsuites` element is not supported by the VSCode Crystal test explorer.
      # puts "<testsuites>"
      # TODO: Support groups
      puts %(<testsuite name="Spectator">)
    end

    def suite_finished : Nil
      write_test_cases
      puts "</testsuite>"
      # puts "</testsuites>"
    end

    private def write_test_cases
      @test_cases.each do |test_case|
        test_case.to_xml(@output)
        puts
      end
    end

    def example_group_started(group : Core::ExampleGroup) : Nil
    end

    def example_group_finished(group : Core::ExampleGroup) : Nil
    end

    def example_started(example : Core::Example) : Nil
    end

    def example_finished(result : Core::ExecutionResult) : Nil
      @test_cases << JUnit::TestCase.from_result(result)
    end

    def report_failures(results : Enumerable(Core::ExecutionResult)) : Nil
    end

    def report_pending(results : Enumerable(Core::ExecutionResult)) : Nil
    end

    def report_profile : Nil
    end

    def report_summary : Nil
    end

    def report_post_summary : Nil
    end
  end
end
