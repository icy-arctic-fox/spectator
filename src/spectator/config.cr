module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    # Used to report test progress and results.
    getter formatter : Formatters::Formatter

    # Creates a new configuration.
    def initialize(@formatter)
    end
  end
end
