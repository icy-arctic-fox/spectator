module Spectator
  # Mutable configuration used to produce a final configuration.
  # Use the setters in this class to incrementally build a configuration.
  # Then call `#build` to create the final configuration.
  class ConfigBuilder
    @formatter : Formatters::Formatter? = nil

    # Sets the formatter to use for reporting test progress and results.
    def formatter=(formatter : Formatters::Formatter)
      @formatter = formatter
    end

    # Retrieves the formatter to use.
    # If one wasn't specified by the user,
    # then `#default_formatter` is returned.
    private def formatter
      @formatter || default_formatter
    end

    # The formatter that should be used,
    # if one wasn't provided.
    private def default_formatter
      Formatters::DefaultFormatter.new
    end

    # Creates a configuration.
    def build : Config
      Config.new(formatter)
    end
  end
end
