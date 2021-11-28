require "colorize"
require "log"
require "./spectator/includes"

# Module that contains all functionality related to Spectator.
module Spectator
  extend self
  include DSL::Top

  # Current version of the Spectator library.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}

  # Logger for Spectator internals.
  ::Log.setup_from_env
  Log = ::Log.for(self)

  # Flag indicating whether Spectator should automatically run tests.
  # This should be left alone (set to true) in typical usage.
  # There are times when Spectator shouldn't run tests.
  # One of those is testing Spectator.
  class_property? autorun = true

  # All tests are ran just before the executable exits.
  # Tests will be skipped, however, if `#autorun?` is set to false.
  # There are a couple of reasons for this.
  #
  # First is that we want a clean interface for the end-user.
  # They shouldn't need to call a "run" method.
  # That adds the burden on the developer to ensure the tests are run after they are created.
  # And that gets complicated when there are multiple files that could run in any order.
  #
  # Second is to allow all of the tests and framework to be constructed.
  # We know that all of the instances and DSL builders have finished
  # after the main part of the executable has run.
  #
  # By doing this, we provide a clean interface and safely run after everything is constructed.
  # The downside, if something bad happens, like an exception is raised,
  # Crystal doesn't display much information about what happened.
  # That issue is handled by putting a begin/rescue block to show a custom error message.
  at_exit do
    # Run only if `#autorun?` is true.
    # Return 1 on failure.
    exit(1) if autorun? && !run
  end

  @@config_builder = Config::Builder.new
  @@config : Config?

  # Provides a means to configure how Spectator will run and report tests.
  # A `ConfigBuilder` is yielded to allow changing the configuration.
  # NOTE: The configuration set here can be overridden
  # with a `.spectator` file and command-line arguments.
  def configure(& : Config::Builder -> _) : Nil
    yield @@config_builder
  end

  # Random number generator for the test suite.
  # All randomly generated values should be pulled from this.
  # This provides re-producible results even though random values are used.
  # The seed for this random generator is controlled by `ConfigBuilder.seed=`.
  def random
    config.random
  end

  # Builds the tests and runs the framework.
  private def run
    # Silence default logger.
    ::Log.setup_from_env(default_level: :none)

    # Build the spec and run it.
    spec = DSL::Builder.build
    spec.run
  rescue ex
    # Re-enable logger for fatal error.
    ::Log.setup_from_env

    # Catch all unhandled exceptions here.
    # Examples are already wrapped, so any exceptions they throw are caught.
    # But if an exception occurs outside an example,
    # it's likely the fault of the test framework (Spectator).
    # So we display a helpful error that could be reported and return non-zero.
    Log.fatal(exception: ex) { "Spectator encountered an unexpected error" }
    false
  end

  # Global configuration used by Spectator for running tests.
  class_getter(config) { build_config }

  # Builds the configuration.
  private def build_config
    # Build up the configuration from various sources.
    # The sources that take priority are later in the list.
    apply_config_file
    apply_command_line_args

    @@config_builder.build
  end

  # Path to the Spectator configuration file.
  # The contents of this file should contain command-line arguments.
  # Those arguments are automatically applied when Spectator starts.
  # Arguments should be placed with one per line.
  CONFIG_FILE_PATH = ".spectator"

  # Loads configuration arguments from a file.
  # The file is expected to be new-line delimited,
  # one argument per line.
  # The arguments are identical to those
  # that would be passed on the command-line.
  private def apply_config_file(file_path = CONFIG_FILE_PATH) : Nil
    return unless File.exists?(file_path)
    args = File.read(file_path).lines
    Config::CLIArgumentsApplicator.new(args).apply(@@config_builder)
  end

  # Applies configuration options from the command-line arguments
  private def apply_command_line_args : Nil
    Config::CLIArgumentsApplicator.new.apply(@@config_builder)
  end
end
