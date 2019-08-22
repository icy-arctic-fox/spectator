require "./spectator/includes"

# Module that contains all functionality related to Spectator.
module Spectator
  extend self

  # Current version of the Spectator library.
  VERSION = "0.8.2"

  # Top-level describe method.
  # All specs in a file must be wrapped in this call.
  # This takes an argument and a block.
  # The argument is what your spec is describing.
  # It can be any Crystal expression,
  # but is typically a class name or feature string.
  # The block should contain all of the specs for what is being described.
  # Example:
  # ```
  # Spectator.describe Foo do
  #   # Your specs for `Foo` go here.
  # end
  # ```
  # NOTE: Inside the block, the `Spectator` prefix is no longer needed.
  # Actually, prefixing methods and macros with `Spectator`
  # most likely won't work and can cause compiler errors.
  macro describe(what, &block)
    # This macro creates the foundation for all specs.
    # Every group of examples is defined a separate module - `SpectatorExamples`.
    # There's multiple reasons for this.
    #
    # The first reason is to provide namespace isolation.
    # We don't want the spec code to accidentally pickup types and values from the `Spectator` module.
    # Another reason is that we need a root module to put all examples and groups in.
    # And lastly, the spec DSL needs to be given to the block of code somehow.
    # The DSL is included in the `SpectatorExamples` module.
    #
    # For more information on how the DSL works, see the `DSL` module.

    # Root-level module that contains all examples and example groups.
    module SpectatorExamples
      # Include the DSL for creating groups, example, and more.
      include ::Spectator::DSL::StructureDSL

      # Placeholder initializer.
      # This is needed because examples and groups call super in their initializer.
      # Those initializers pass the sample values upward through their hierarchy.
      def initialize(_sample_values : ::Spectator::Internals::SampleValues)
      end

      # Pass off the "what" argument and block to `DSL::StructureDSL.describe`.
      # That method will handle creating a new group for this spec.
      describe({{what}}) {{block}}
    end
  end

  # ditto
  macro context(what, &block)
    describe({{what}}) {{block}}
  end

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

  @@config_builder = ConfigBuilder.new
  @@config : Config?

  # Provides a means to configure how Spectator will run and report tests.
  # A `ConfigBuilder` is yielded to allow changing the configuration.
  # NOTE: The configuration set here can be overriden
  # with a `.spectator` file and command-line arguments.
  def configure : Nil
    yield @@config_builder
  end

  # Random number generator for the test suite.
  # All randomly generated values should be pulled from this.
  # This provides reproducable results even though random values are used.
  # The seed for this random generator is controlled by `ConfigBuilder.seed=`.
  def random
    config.random
  end

  # Builds the tests and runs the framework.
  private def run
    # Build the test suite and run it.
    suite = ::Spectator::DSL::Builder.build(config.example_filter)
    Runner.new(suite, config).run
  rescue ex
    # Catch all unhandled exceptions here.
    # Examples are already wrapped, so any exceptions they throw are caught.
    # But if an exception occurs outside an example,
    # it's likely the fault of the test framework (Spectator).
    # So we display a helpful error that could be reported and return non-zero.
    display_error_stack(ex)
    false
  end

  # Processes and builds up a configuration to use for running tests.
  private def config
    @@config ||= build_config
  end

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
    CommandLineArgumentsConfigSource.new(args).apply_to(@@config_builder)
  end

  # Applies configuration options from the command-line arguments
  private def apply_command_line_args : Nil
    CommandLineArgumentsConfigSource.new.apply_to(@@config_builder)
  end

  # Displays a complete error stack.
  # Prints an error and everything that caused it.
  # Stacktrace is included.
  private def display_error_stack(error) : Nil
    puts
    puts "Encountered an unexpected error in framework"
    # Loop while there's a cause for the error.
    # Print each error in the stack.
    loop do
      display_error(error)
      error = error.cause
      break unless error
    end
  end

  # Display a single error and its stacktrace.
  private def display_error(error) : Nil
    puts
    puts "Caused by: #{error.message}"
    puts error.backtrace.join("\n")
  end
end
