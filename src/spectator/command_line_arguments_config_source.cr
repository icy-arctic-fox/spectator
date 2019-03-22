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
        parser.on("-v", "--verbose", "Verbose output using document formatter") { builder.formatter = Formatting::DocumentFormatter.new }
        parser.on("-f", "--fail-fast", "Stop testing on first failure") { builder.fail_fast }
        parser.on("-h", "--help", "Show this help") { puts parser; exit }
      end
    end
  end
end
