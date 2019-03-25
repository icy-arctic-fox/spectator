module Spectator
  # Mutable configuration used to produce a final configuration.
  # Use the setters in this class to incrementally build a configuration.
  # Then call `#build` to create the final configuration.
  class ConfigBuilder
    # Creates a default configuration.
    def self.default
      new.build
    end

    # Random number generator to use.
    protected getter random = Random::DEFAULT

    @primary_formatter : Formatting::Formatter?
    @additional_formatters = [] of Formatting::Formatter
    @fail_fast = false
    @fail_blank = false
    @dry_run = false
    @randomize = false
    @profile = false
    @filters = [] of ExampleFilter

    # Sets the primary formatter to use for reporting test progress and results.
    def formatter=(formatter : Formatting::Formatter)
      @primary_formatter = formatter
    end

    # Adds an extra formater to use for reporting test progress and results.
    def add_formatter(formatter : Formatting::Formatter)
      @additional_formatters << formatter
    end

    # Retrieves the formatters to use.
    # If one wasn't specified by the user,
    # then `#default_formatter` is returned.
    protected def formatters
      @additional_formatters + [(@primary_formatter || default_formatter)]
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
    protected def fail_fast?
      @fail_fast
    end

    # Enables fail-blank mode (fail on no tests).
    def fail_blank
      self.fail_blank = true
    end

    # Enables or disables fail-blank mode.
    def fail_blank=(flag)
      @fail_blank = flag
    end

    # Indicates whether fail-fast mode is enabled.
    # That is, it is a failure if there are no tests.
    protected def fail_blank?
      @fail_blank
    end

    # Enables dry-run mode.
    def dry_run
      self.dry_run = true
    end

    # Enables or disables dry-run mode.
    def dry_run=(flag)
      @dry_run = flag
    end

    # Indicates whether dry-run mode is enabled.
    # In this mode, no tests are run, but output acts like they were.
    protected def dry_run?
      @dry_run
    end

    # Sets the seed for the random number generator.
    def seed=(seed)
      @random = Random.new(seed)
    end

    # Randomizes test execution order.
    def randomize
      self.randomize = true
    end

    # Enables or disables running tests in a random order.
    def randomize=(flag)
      @randomize = flag
    end

    # Indicates whether tests are run in a random order.
    protected def randomize?
      @randomize
    end

    # Displays profiling information
    def profile
      self.profile = true
    end

    # Enables or disables displaying profiling information.
    def profile=(flag)
      @profile = flag
    end

    # Indicates whether profiling information should be displayed.
    protected def profile?
      @profile
    end

    # Adds a filter to determine which examples can run.
    def add_example_filter(filter : ExampleFilter)
      @filters << filter
    end

    # Retrieves a filter that determines which examples can run.
    # If no filters were added with `#add_example_filter`,
    # then the returned filter will allow all examples to be run.
    protected def example_filter
      if @filters.empty?
        NullExampleFilter.new
      else
        CompositeExampleFilter.new(@filters)
      end
    end

    # Creates a configuration.
    def build : Config
      Config.new(self)
    end
  end
end
