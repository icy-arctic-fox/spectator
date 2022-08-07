require "colorize"
require "option_parser"
require "../formatting"
require "../line_node_filter"
require "../location"
require "../location_node_filter"
require "../name_node_filter"
require "../tag_node_filter"

module Spectator
  class Config
    # Applies command-line arguments to a configuration.
    class CLIArgumentsApplicator
      # Logger for this class.
      Log = Spectator::Log.for("config")

      # Creates the configuration source.
      # By default, the command-line arguments (ARGV) are used.
      # But custom arguments can be passed in.
      def initialize(@args : Array(String) = ARGV)
      end

      # Applies the specified configuration to a builder.
      # Calling this method from multiple sources builds up the final configuration.
      def apply(builder) : Nil
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
          Log.debug { "Enabling fail-fast (-f)" }
          builder.fail_fast
        end
      end

      # Adds the fail-blank option to the parser.
      private def fail_blank_option(parser, builder)
        parser.on("-b", "--fail-blank", "Fail if there are no examples") do
          Log.debug { "Enabling fail-blank (-b)" }
          builder.fail_blank
        end
      end

      # Adds the dry-run option to the parser.
      private def dry_run_option(parser, builder)
        parser.on("-d", "--dry-run", "Don't run any tests, output what would have run") do
          Log.debug { "Enabling dry-run (-d)" }
          builder.dry_run
        end
      end

      # Adds the randomize examples option to the parser.
      private def random_option(parser, builder)
        parser.on("-r", "--rand", "Randomize the execution order of tests") do
          Log.debug { "Randomizing test order (-r)" }
          builder.randomize
        end
      end

      # Adds the random seed option to the parser.
      private def seed_option(parser, builder)
        parser.on("--seed INTEGER", "Set the seed for the random number generator (implies -r)") do |seed|
          Log.debug { "Randomizing test order and setting RNG seed to #{seed}" }
          builder.randomize
          builder.random_seed = seed.to_u64
        end
      end

      # Adds the example order option to the parser.
      private def order_option(parser, builder)
        parser.on("--order ORDER", "Set the test execution order. ORDER should be one of: defined, rand, or rand:SEED") do |method|
          case method.downcase
          when "defined"
            Log.debug { "Disabling randomized tests (--order defined)" }
            builder.randomize = false
          when /^rand/
            builder.randomize
            parts = method.split(':', 2)
            if (seed = parts[1]?)
              Log.debug { "Randomizing test order and setting RNG seed to #{seed} (--order rand:#{seed})" }
              builder.random_seed = seed.to_u64
            else
              Log.debug { "Randomizing test order (--order rand)" }
            end
          end
        end
      end

      # Adds options to the parser for filtering examples.
      private def filter_parser_options(parser, builder)
        example_option(parser, builder)
        line_option(parser, builder)
        location_option(parser, builder)
        tag_option(parser, builder)
      end

      # Adds the example filter option to the parser.
      private def example_option(parser, builder)
        parser.on("-e", "--example STRING", "Run examples whose full nested names include STRING") do |pattern|
          Log.debug { "Filtering for examples containing '#{pattern}' (-e '#{pattern}')" }
          filter = NameNodeFilter.new(pattern)
          builder.add_node_filter(filter)
        end
      end

      # Adds the line filter option to the parser.
      private def line_option(parser, builder)
        parser.on("-l", "--line LINE", "Run examples whose line matches LINE") do |line|
          Log.debug { "Filtering for examples on line #{line} (-l #{line})" }
          filter = LineNodeFilter.new(line.to_i)
          builder.add_node_filter(filter)
        end
      end

      # Adds the location filter option to the parser.
      private def location_option(parser, builder)
        parser.on("--location FILE:LINE", "Run the example at line 'LINE' in the file 'FILE', multiple allowed") do |location|
          Log.debug { "Filtering for examples at #{location} (--location '#{location}')" }
          location = Location.parse(location)
          filter = LocationNodeFilter.new(location)
          builder.add_node_filter(filter)
        end
      end

      # Adds the tag filter option to the parser.
      private def tag_option(parser, builder)
        parser.on("--tag TAG[:VALUE]", "Run examples with the specified TAG, or exclude examples by adding ~ before the TAG.") do |tag|
          negated = tag.starts_with?('~')
          tag = tag.lchop('~')
          Log.debug { "Filtering for example with tag #{tag}" }
          parts = tag.split(':', 2, remove_empty: true)
          if parts.size > 1
            tag = parts.first
            value = parts.last
          end

          filter = TagNodeFilter.new(tag, value)
          if negated
            builder.add_node_reject(filter)
          else
            builder.add_node_filter(filter)
          end
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
        html_option(parser, builder)
        no_color_option(parser, builder)
      end

      # Adds the verbose output option to the parser.
      private def verbose_option(parser, builder)
        parser.on("-v", "--verbose", "Verbose output using document formatter") do
          Log.debug { "Setting output format to document (-v)" }
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
          Log.debug { "Enabling timing information (-p)" }
          builder.profile
        end
      end

      # Adds the JSON output option to the parser.
      private def json_option(parser, builder)
        parser.on("--json", "Generate JSON output") do
          Log.debug { "Setting output format to JSON (--json)" }
          builder.formatter = Formatting::JSONFormatter.new
        end
      end

      # Adds the TAP output option to the parser.
      private def tap_option(parser, builder)
        parser.on("--tap", "Generate TAP output (Test Anything Protocol)") do
          Log.debug { "Setting output format to TAP (--tap)" }
          builder.formatter = Formatting::TAPFormatter.new
        end
      end

      # Adds the JUnit output option to the parser.
      private def junit_option(parser, builder)
        parser.on("--junit_output OUTPUT_DIR", "Generate JUnit XML output") do |output_dir|
          Log.debug { "Setting output format to JUnit XML (--junit_output '#{output_dir}')" }
          formatter = Formatting::JUnitFormatter.new(output_dir)
          builder.add_formatter(formatter)
        end
      end

      # Adds the HTML output option to the parser.
      private def html_option(parser, builder)
        parser.on("--html_output OUTPUT_DIR", "Generate HTML output") do |output_dir|
          Log.debug { "Setting output format to HTML (--html_output '#{output_dir}')" }
          formatter = Formatting::HTMLFormatter.new(output_dir)
          builder.add_formatter(formatter)
        end
      end

      # Adds the "no color" output option to the parser.
      private def no_color_option(parser, builder)
        parser.on("--no-color", "Disable colored output") do
          Log.debug { "Disabling color output (--no-color)" }
          Colorize.enabled = false
        end
      end
    end
  end
end
