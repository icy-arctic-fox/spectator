module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    # Used to report test progress and results.
    getter formatter : Formatting::Formatter

    # Indicates whether the test should abort on first failure.
    getter? fail_fast : Bool

    # Indicates whether the test should fail if there are no examples.
    getter? fail_blank : Bool

    # Indicates whether the test should be done as a dry-run.
    # Examples won't run, but the output will show that they did.
    getter? dry_run : Bool

    # Creates a new configuration.
    def initialize(builder)
      @formatter = builder.formatter
      @fail_fast = builder.fail_fast?
      @fail_blank = builder.fail_blank?
      @dry_run = builder.dry_run?
    end
  end
end
