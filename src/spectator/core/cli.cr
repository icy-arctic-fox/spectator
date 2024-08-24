require "option_parser"
require "../formatters/*"
require "./configuration"
require "./filters"

module Spectator::Core
  module CLI
    extend self

    def configure(args = ARGV, env = ENV, configuration = Spectator.configuration) : Nil
      option_parser = build_option_parser(configuration)

      # Apply configuration files.
      each_configuration_file(env) do |file|
        if File.file?(file)
          options = Process.parse_arguments(File.read(file))
          option_parser.parse(options)
        end
      end

      # Apply environment variables.
      if env_options = env["SPEC_OPTS"]?
        option_parser.parse(env_options.split)
      end

      # Apply command line options.
      option_parser.parse(args)
    end

    def parse(args = ARGV, configuration = Spectator.configuration) : Nil
      build_option_parser(configuration).parse(args)
    end

    private def each_configuration_file(env = ENV, & : String ->) : Nil
      files = Array(String).new(4)
      if xdg_config_home = env["XDG_CONFIG_HOME"]?
        xdg_options_file = File.join(xdg_config_home, "spectator", "options")
        files << xdg_options_file if File.file?(xdg_options_file)
      end
      if files.empty? && (home_dir = env["HOME"]?)
        files << File.join(home_dir, ".spectator")
      end
      files << ".spectator"
      files << ".spectator-local"
      files
    end

    private def build_option_parser(configuration : Configuration) : OptionParser
      configure_inclusion_filter = Proc(CompoundFilter).new do
        filter = configuration.inclusion_filter
        next filter if filter.is_a?(CompoundFilter)
        filter = CompoundFilter.new(filter ? [filter] of Filter : [] of Filter)
        configuration.inclusion_filter = filter
      end

      OptionParser.new do |parser|
        parser.banner = "Usage: crystal spec [options] [files] [runtime_options]"

        parser.on("-e", "--example STRING", "Run examples whose full nested names include STRING") do
          # TODO
        end

        parser.on("-l", "--line LINE", "Run examples whose line matches LINE") do |line|
          filter = configure_inclusion_filter.call
          filter.add_filter(LineFilter.new(line: line.to_i))
        end

        parser.on("-p [NUMBER]", "--profile [NUMBER]", "Print the NUMBER slowest specs (default: 10)") do
          # TODO
        end

        parser.on("--fail-fast [NUMBER]", "Abort the run on first NUMBER failures (default: 1)") do
          # TODO
        end

        parser.on("--location FILE:LINE", "Run example at LINE in FILE, multiple allowed") do |location|
          filter = configure_inclusion_filter.call
          filter.add_filter(LocationFilter.new(Location.parse(location)))
        end

        parser.on("--tag TAG", "Run examples with the specified TAG, or exclude examples by adding ~ before the TAG") do
          # TODO
        end

        parser.on("--list-tags", "Lists all the tags used") do
          # TODO
        end

        parser.on("--order MODE", "Run examples in random order by passing MODE as 'random' or to a specific seed by passing MODE as the seed value") do
          # TODO
        end

        parser.on("--junit_output OUTPUT_PATH", "Generate JUnit XML output within the given OUTPUT_PATH") do |output_path|
          configuration.add_formatter(Formatters::CompatibleJUnitFormatter.file(output_path))
        end

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end

        parser.on("-v", "--verbose", "Enable verbose output") do
          # TODO
        end

        parser.on("--tap", "Generate TAP output (Test Anything Protocol)") do
          # TODO
        end

        parser.on("--color", "Enable ANSI colored output") do
          Colorize.enabled = true
        end

        parser.on("--no-color", "Disable ANSI colored output") do
          Colorize.enabled = false
        end

        parser.on("--dry-run", "Pass all tests without execution") do
          configuration.dry_run = true
        end
      end
    end
  end
end
