module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    # Used to report test progress and results.
    getter formatter : Formatting::Formatter

    # Indicates whether the test should abort on first failure.
    getter? fail_fast : Bool

    # Creates a new configuration.
    def initialize(builder)
      @formatter = builder.formatter
      @fail_fast = builder.fail_fast?
    end
  end
end
