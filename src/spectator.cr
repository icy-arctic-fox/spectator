require "./spectator/includes"

# Module that contains all functionality related to Spectator.
module Spectator
  # Current version of the Spectator library.
  VERSION = "0.1.0"

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

      # Pass off the "what" argument and block to `DSL::StructureDSL.describe`.
      # That method will handle creating a new group for this spec.
      describe({{what}}) {{block}}
    end
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
    run if autorun?
  end

  # Builds the tests and runs the framework.
  private def self.run
    # Build the test suite and run it.
    suite = ::Spectator::DSL::Builder.build
    Runner.new(suite).run
  rescue ex
    # Catch all unhandled exceptions here.
    # Examples are already wrapped, so any exceptions they throw are caught.
    # But if an exception occurs outside an example,
    # it's likely the fault of the test framework (Spectator).
    # So we display a helpful error that could be reported and return non-zero.
    display_error(ex)
    exit(1)
  end

  # Displays an error message.
  private def self.display_error(error)
    puts
    puts "Encountered an unexpected error in framework"
    puts error.message
    puts error.backtrace.join("\n")
  end
end
