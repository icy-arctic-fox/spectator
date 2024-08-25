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

  class_property? auto_run = true

  def self.run
    Core::CLI.configure
    runner = Core::Runner.new(configuration)
    runner.run(sandbox.root_example_group)
  rescue ex
    STDERR.puts "Spectator encountered an unexpected error."
    ex.inspect_with_backtrace(STDERR)
    exit 1
  end

  at_exit do
    run if auto_run?
  end
end
