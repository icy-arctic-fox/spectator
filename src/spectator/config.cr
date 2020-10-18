require "./example_filter"
require "./formatting"

module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    @formatters : Array(Formatting::Formatter)

    # Indicates whether the test should abort on first failure.
    getter? fail_fast : Bool

    # Indicates whether the test should fail if there are no examples.
    getter? fail_blank : Bool

    # Indicates whether the test should be done as a dry-run.
    # Examples won't run, but the output will show that they did.
    getter? dry_run : Bool

    # Indicates whether examples run in a random order.
    getter? randomize : Bool

    # Seed used for random number generation.
    getter random_seed : UInt64

    # Indicates whether timing information should be displayed.
    getter? profile : Bool

    # Filter determining examples to run.
    getter example_filter : ExampleFilter

    # Creates a new configuration.
    # Properties are pulled from *source*.
    # Typically, *source* is a `ConfigBuilder`.
    def initialize(source)
      @formatters = source.formatters
      @fail_fast = source.fail_fast?
      @fail_blank = source.fail_blank?
      @dry_run = source.dry_run?
      @randomize = source.randomize?
      @random_seed = source.random_seed
      @profile = source.profile?
      @example_filter = source.example_filter
    end

    # Shuffles the items in an array using the configured random settings.
    # If `#randomize?` is true, the *items* are shuffled and returned as a new array.
    # Otherwise, the items are left alone and returned as-is.
    # The array of *items* is never modified.
    def shuffle(items)
      return items unless randomize?

      items.shuffle(random)
    end

    # Shuffles the items in an array using the configured random settings.
    # If `#randomize?` is true, the *items* are shuffled and returned.
    # Otherwise, the items are left alone and returned as-is.
    # The array of *items* is modified, the items are shuffled in-place.
    def shuffle!(items)
      return items unless randomize?

      items.shuffle!(random)
    end

    # Yields each formatter that should be reported to.
    def each_formatter
      @formatters.each do |formatter|
        yield formatter
      end
    end

    # Retrieves the configured random number generator.
    # This will produce the same generator with the same seed every time.
    private def random
      Random.new(random_seed)
    end
  end
end
