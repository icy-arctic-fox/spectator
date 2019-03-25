require "option_parser"

module Spectator
  # Generates configuration from the command-line arguments.
  class CommandLineArgumentsConfigSource < ConfigSource
    # Creates the configuration source.
    # By default, the command-line arguments (ARGV) are used.
    # But custom arguments can be passed in.
    def initialize(@args : Array(String) = ARGV)
    end

    # Applies the specified configuration to a builder.
    # Calling this method from multiple sources builds up the final configuration.
    def apply_to(builder : ConfigBuilder) : Nil
      OptionParser.parse(@args) do |parser|
        control_parser_options(parser, builder)
        filter_parser_options(parser, builder)
        output_parser_options(parser, builder)
      end
    end

    # Adds options to the parser for controlling the test execution.
    private def control_parser_options(parser, builder)
      fail_fast_option(parser, builder)
      fail_blank_option(parser, builder)
      dry_run_option(parser, builder)
      random_option(parser, builder)
      seed_option(parser, builder)
      order_option(parser, builder)
    end

    # Adds the fail-fast option to the parser.
    private def fail_fast_option(parser, builder)
      parser.on("-f", "--fail-fast", "Stop testing on first failure") do
        builder.fail_fast
      end
    end

    # Adds the fail-blank option to the parser.
    private def fail_blank_option(parser, builder)
      parser.on("-b", "--fail-blank", "Fail if there are no examples") do
        builder.fail_blank
      end
    end

    # Adds the dry-run option to the parser.
    private def dry_run_option(parser, builder)
      parser.on("-d", "--dry-run", "Don't run any tests, output what would have run") do
        builder.dry_run
      end
    end

    # Adds the randomize examples option to the parser.
    private def random_option(parser, builder)
      parser.on("-r", "--rand", "Randomize the execution order of tests") do
        builder.randomize
      end
    end

    # Adds the random seed option to the parser.
    private def seed_option(parser, builder)
      parser.on("--seed INTEGER", "Set the seed for the random number generator (implies -r)") do |seed|
        builder.randomize
        builder.seed = seed.to_i
      end
    end

    # Adds the example order option to the parser.
    private def order_option(parser, builder)
      parser.on("--order ORDER", "Set the test execution order. ORDER should be one of: defined, rand, or rand:SEED") do |method|
        case method.downcase
        when "defined"
          builder.randomize = false
        when /^rand/
          builder.randomize
          parts = method.split(':', 2)
          builder.seed = parts[1].to_i if parts.size > 1
        end
      end
    end

    # Adds options to the parser for filtering examples.
    private def filter_parser_options(parser, builder)
      example_option(parser, builder)
      line_option(parser, builder)
      location_option(parser, builder)
    end

    # Adds the example filter option to the parser.
    private def example_option(parser, builder)
      parser.on("-e", "--example STRING", "Run examples whose full nested names include STRING") do |pattern|
        filter = NameExampleFilter.new(pattern)
        builder.add_example_filter(filter)
      end
    end

    # Adds the line filter option to the parser.
    private def line_option(parser, builder)
      parser.on("-l", "--line LINE", "Run examples whose line matches LINE") do |line|
        filter = LineExampleFilter.new(line.to_i)
        builder.add_example_filter(filter)
      end
    end

    # Adds the location filter option to the parser.
    private def location_option(parser, builder)
      parser.on("--location FILE:LINE", "Run the example at line 'LINE' in the file 'FILE', multiple allowed") do |location|
        source = Source.parse(location)
        filter = SourceExampleFilter.new(source)
        builder.add_example_filter(filter)
      end
    end

    # Adds options to the parser for changing output.
    private def output_parser_options(parser, builder)
      verbose_option(parser, builder)
      help_option(parser, builder)
      profile_option(parser, builder)
      json_option(parser, builder)
      tap_option(parser, builder)
      junit_option(parser, builder)
      no_color_option(parser, builder)
    end

    # Adds the verbose output option to the parser.
    private def verbose_option(parser, builder)
      parser.on("-v", "--verbose", "Verbose output using document formatter") do
        builder.formatter = Formatting::DocumentFormatter.new
      end
    end

    # Adds the help output option to the parser.
    private def help_option(parser, builder)
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end
    end

    # Adds the profile output option to the parser.
    private def profile_option(parser, builder)
      parser.on("-p", "--profile", "Display the 10 slowest specs") do
        builder.profile
      end
    end

    # Adds the JSON output option to the parser.
    private def json_option(parser, builder)
      parser.on("--json", "Generate JSON output") do
        builder.formatter = Formatting::JsonFormatter.new
      end
    end

    # Adds the TAP output option to the parser.
    private def tap_option(parser, builder)
      parser.on("--tap", "Generate TAP output (Test Anything Protocol)") do
        builder.formatter = Formatting::TAPFormatter.new
      end
    end

    # Adds the JUnit output option to the parser.
    private def junit_option(parser, builder)
      parser.on("--junit_output OUTPUT_DIR", "Generate JUnit XML output") do |output_dir|
        formatter = Formatting::JUnitFormatter.new(output_dir)
        builder.add_formatter(formatter)
      end
    end

    # Adds the "no color" output option to the parser.
    private def no_color_option(parser, builder)
      parser.on("--no-color", "Disable colored output") do
        Colorize.enabled = false
      end
    end
  end
end
