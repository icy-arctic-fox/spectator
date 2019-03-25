module Spectator::Formatting
  # Formatter for the "Test Anything Protocol".
  # For details, see: https://testanything.org/
  class TAPFormatter < Formatter
    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
      @index = 1
    end

    # Called when a test suite is starting to execute.
    def start_suite(suite : TestSuite)
      @io << "1.."
      @io.puts suite.size
    end

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    # The *profile* value is not nil when profiling results should be displayed.
    def end_suite(report : Report, profile : Profile?)
      @io.puts "Bail out!" if report.remaining?
      profile(profile) if profile
    end

    # Called before a test starts.
    def start_example(example : Example)
    end

    # Called when a test finishes.
    # The result of the test is provided.
    def end_example(result : Result)
      @io.puts TAPTestLine.new(@index, result)
      @index += 1
    end

    # Displays profiling information.
    private def profile(profile)
      @io.puts(Comment.new(ProfileSummary.new(profile)))

      indent = Indent.new(@io)
      indent.increase do
        profile.each do |result|
          profile_entry(indent, result)
        end
      end
    end

    # Adds a profile result entry to the output.
    private def profile_entry(indent, result)
      @io << "# "
      indent.line(result.example)
      indent.increase do
        @io << "# "
        indent.line(SourceTiming.new(result.elapsed, result.example.source))
      end
    end
  end
end
