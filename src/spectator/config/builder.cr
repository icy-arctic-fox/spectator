require "../composite_example_filter"
require "../example_filter"
require "../formatting"
require "../null_example_filter"
require "../run_flags"

module Spectator
  class Config
    # Mutable configuration used to produce a final configuration.
    # Use the setters in this class to incrementally build a configuration.
    # Then call `#build` to create the final configuration.
    class Builder
      # Seed used for random number generation.
      property random_seed : UInt64 = Random.rand(UInt64)

      # Toggles indicating how the test spec should execute.
      property run_flags = RunFlags::None

      @primary_formatter : Formatting::Formatter?
      @additional_formatters = [] of Formatting::Formatter
      @filters = [] of ExampleFilter

      # Creates a configuration.
      def build : Config
        Config.new(self)
      end

      # Sets the primary formatter to use for reporting test progress and results.
      def formatter=(formatter : Formatting::Formatter)
        @primary_formatter = formatter
      end

      # Adds an extra formatter to use for reporting test progress and results.
      def add_formatter(formatter : Formatting::Formatter)
        @additional_formatters << formatter
      end

      # Retrieves the formatters to use.
      # If one wasn't specified by the user,
      # then `#default_formatter` is returned.
      private def formatters
        @additional_formatters + [(@primary_formatter || default_formatter)]
      end

      # The formatter that should be used if one wasn't provided.
      private def default_formatter
        Formatting::ProgressFormatter.new
      end

      # A single formatter that will satisfy the configured output.
      # If one formatter was configured, then it is returned.
      # Otherwise, a `Formatting::BroadcastFormatter` is returned.
      protected def formatter
        case (formatters = self.formatters)
        when .one? then formatters.first
        else Formatting::BroadcastFormatter.new(formatters)
        end
      end

      # Enables fail-fast mode.
      def fail_fast
        @run_flags |= RunFlags::FailFast
      end

      # Sets the fail-fast flag.
      def fail_fast=(flag)
        if flag
          @run_flags |= RunFlags::FailFast
        else
          @run_flags &= ~RunFlags::FailFast
        end
      end

      # Indicates whether fail-fast mode is enabled.
      protected def fail_fast?
        @run_flags.fail_fast?
      end

      # Enables fail-blank mode (fail on no tests).
      def fail_blank
        @run_flags |= RunFlags::FailBlank
      end

      # Enables or disables fail-blank mode.
      def fail_blank=(flag)
        if flag
          @run_flags |= RunFlags::FailBlank
        else
          @run_flags &= ~RunFlags::FailBlank
        end
      end

      # Indicates whether fail-fast mode is enabled.
      # That is, it is a failure if there are no tests.
      protected def fail_blank?
        @run_flags.fail_blank?
      end

      # Enables dry-run mode.
      def dry_run
        @run_flags |= RunFlags::DryRun
      end

      # Enables or disables dry-run mode.
      def dry_run=(flag)
        if flag
          @run_flags |= RunFlags::DryRun
        else
          @run_flags &= ~RunFlags::DryRun
        end
      end

      # Indicates whether dry-run mode is enabled.
      # In this mode, no tests are run, but output acts like they were.
      protected def dry_run?
        @run_flags.dry_run?
      end

      # Randomizes test execution order.
      def randomize
        @run_flags |= RunFlags::Randomize
      end

      # Enables or disables running tests in a random order.
      def randomize=(flag)
        if flag
          @run_flags |= RunFlags::Randomize
        else
          @run_flags &= ~RunFlags::Randomize
        end
      end

      # Indicates whether tests are run in a random order.
      protected def randomize?
        @run_flags.randomize?
      end

      # Displays profiling information
      def profile
        @run_flags |= RunFlags::Profile
      end

      # Enables or disables displaying profiling information.
      def profile=(flag)
        if flag
          @run_flags |= RunFlags::Profile
        else
          @run_flags &= ~RunFlags::Profile
        end
      end

      # Indicates whether profiling information should be displayed.
      protected def profile?
        @run_flags.profile?
      end

      # Adds a filter to determine which examples can run.
      def add_example_filter(filter : ExampleFilter)
        @filters << filter
      end

      # Retrieves a filter that determines which examples can run.
      # If no filters were added with `#add_example_filter`,
      # then the returned filter will allow all examples to be run.
      protected def example_filter
        case (filters = @filters)
        when .empty? then NullExampleFilter.new
        when .one? then filters.first
        else CompositeExampleFilter.new(filters)
        end
      end
    end
  end
end
