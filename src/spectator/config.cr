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

    # Random number generator to use for everything.
    getter random : Random

    # Indicates whether tests are run in a random order.
    getter? randomize : Bool

    # Indicates whether profiling information should be displayed.
    getter? profile : Bool

    # Filter that determines which examples to run.
    getter example_filter : ExampleFilter

    # Creates a new configuration.
    def initialize(builder)
      @formatters = builder.formatters
      @fail_fast = builder.fail_fast?
      @fail_blank = builder.fail_blank?
      @dry_run = builder.dry_run?
      @random = builder.random
      @randomize = builder.randomize?
      @profile = builder.profile?
      @example_filter = builder.example_filter
    end

    # Yields each formatter that should be reported to.
    def each_formatter
      @formatters.each do |formatter|
        yield formatter
      end
    end
  end
end
