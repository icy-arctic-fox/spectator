require "./config/*"
require "./example_filter"
require "./example_group"
require "./example_iterator"
require "./formatting/formatter"
require "./run_flags"

module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    # Primary formatter all events will be sent to.
    getter formatter : Formatting::Formatter

    # Flags indicating how the spec should run.
    getter run_flags : RunFlags

    # Seed used for random number generation.
    getter random_seed : UInt64

    # Filter used to select which examples to run.
    getter example_filter : ExampleFilter

    # List of hooks to run before all examples in the test suite.
    protected getter before_suite_hooks : Array(ExampleGroupHook)

    # List of hooks to run before each top-level example group.
    protected getter before_all_hooks : Array(ExampleGroupHook)

    # List of hooks to run before every example.
    protected getter before_each_hooks : Array(ExampleHook)

    # List of hooks to run after all examples in the test suite.
    protected getter after_suite_hooks : Array(ExampleGroupHook)

    # List of hooks to run after each top-level example group.
    protected getter after_all_hooks : Array(ExampleGroupHook)

    # List of hooks to run after every example.
    protected getter after_each_hooks : Array(ExampleHook)

    # List of hooks to run around every example.
    protected getter around_each_hooks : Array(ExampleProcsyHook)

    # Creates a new configuration.
    # Properties are pulled from *source*.
    # Typically, *source* is a `Config::Builder`.
    def initialize(source)
      @formatter = source.formatter
      @run_flags = source.run_flags
      @random_seed = source.random_seed
      @example_filter = source.example_filter

      @before_suite_hooks = source.before_suite_hooks
      @before_all_hooks = source.before_all_hooks
      @before_each_hooks = source.before_each_hooks
      @after_suite_hooks = source.after_suite_hooks
      @after_all_hooks = source.after_all_hooks
      @after_each_hooks = source.after_each_hooks
      @around_each_hooks = source.around_each_hooks
    end

    # Produces the default configuration.
    def self.default : self
      Builder.new.build
    end

    # Shuffles the items in an array using the configured random settings.
    # If `#randomize?` is true, the *items* are shuffled and returned as a new array.
    # Otherwise, the items are left alone and returned as-is.
    # The array of *items* is never modified.
    def shuffle(items)
      return items unless run_flags.randomize?

      items.shuffle(random)
    end

    # Shuffles the items in an array using the configured random settings.
    # If `#randomize?` is true, the *items* are shuffled and returned.
    # Otherwise, the items are left alone and returned as-is.
    # The array of *items* is modified, the items are shuffled in-place.
    def shuffle!(items)
      return items unless run_flags.randomize?

      items.shuffle!(random)
    end

    # Creates an iterator configured to select the filtered examples.
    def iterator(group : ExampleGroup)
      ExampleIterator.new(group).select(@example_filter)
    end

    # Retrieves the configured random number generator.
    # This will produce the same generator with the same seed every time.
    def random
      Random.new(random_seed)
    end
  end
end
