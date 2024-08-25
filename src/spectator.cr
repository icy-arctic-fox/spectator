require "./spectator/assertion_failed"
require "./spectator/error"
require "./spectator/example_skipped"
require "./spectator/framework_error"

require "./spectator/core/**"
require "./spectator/matchers/**"

# Feature-rich testing framework for Crystal inspired by RSpec.
module Spectator
  # Current version of the Spectator library.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}

  # Indicates whether tests will run automatically after all examples and groups have been defined.
  # Disable this to prevent tests from running automatically.
  class_property? auto_run = true

  # Runs all examples in the current sandbox.
  # The application's command-line arguments and environment variables are used for configuration.
  def self.run
    Core::CLI.configure
    runner = Core::Runner.new(configuration)
    runner.run(sandbox.root_example_group)
  rescue ex
    STDERR.puts "Spectator encountered an unexpected error."
    ex.inspect_with_backtrace(STDERR)
    exit 1
  end

  at_exit { run if auto_run? }
end
