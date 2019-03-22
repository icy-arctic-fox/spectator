module Spectator
  # Mutable configuration used to produce a final configuration.
  # Use the setters in this class to incrementally build a configuration.
  # Then call `#build` to create the final configuration.
  class ConfigBuilder
    # Creates a default configuration.
    def self.default
      new.build
    end

    @formatter : Formatting::Formatter? = nil
    @fail_fast = false

    # Sets the formatter to use for reporting test progress and results.
    def formatter=(formatter : Formatting::Formatter)
      @formatter = formatter
    end

    # Retrieves the formatter to use.
    # If one wasn't specified by the user,
    # then `#default_formatter` is returned.
    def formatter
      @formatter || default_formatter
    end

    # The formatter that should be used,
    # if one wasn't provided.
    private def default_formatter
      Formatting::DotsFormatter.new
    end

    # Enables fail-fast mode.
    def fail_fast
      self.fail_fast = true
    end

    # Sets the fail-fast flag.
    def fail_fast=(flag)
      @fail_fast = flag
    end

    # Indicates whether fail-fast mode is enabled.
    def fail_fast?
      @fail_fast
    end

    # Creates a configuration.
    def build : Config
      Config.new(self)
    end
  end
end
