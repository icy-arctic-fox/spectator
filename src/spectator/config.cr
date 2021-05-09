require "./example_filter"
require "./formatting"
require "./run_flags"

module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    @formatters : Array(Formatting::Formatter)

    # Flags indicating how the spec should run.
    getter run_flags : RunFlags

    # Seed used for random number generation.
    getter random_seed : UInt64

    # Creates a new configuration.
    # Properties are pulled from *source*.
    # Typically, *source* is a `ConfigBuilder`.
    def initialize(source)
      @formatters = source.formatters
      @run_flags = source.run_flags
      @random_seed = source.random_seed
      @example_filter = source.example_filter
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
