require "../composite_node_filter"
require "../node_filter"
require "../formatting"
require "../metadata"
require "../null_node_filter"
require "../run_flags"
require "../tag_node_filter"

module Spectator
  class Config
    # Mutable configuration used to produce a final configuration.
    # Use the setters in this class to incrementally build a configuration.
    # Then call `#build` to create the final configuration.
    class Builder
      # Seed used for random number generation.
      property random_seed : UInt64 = Random.rand(100000_u64)

      # Toggles indicating how the test spec should execute.
      property run_flags = RunFlags::None

      protected getter match_filters : Metadata = {:focus => nil.as(String?)}

      @primary_formatter : Formatting::Formatter?
      @additional_formatters = [] of Formatting::Formatter
      @filters = [] of NodeFilter
      @rejects = [] of NodeFilter

      # List of hooks to run before all examples in the test suite.
      protected getter before_suite_hooks = Deque(ExampleGroupHook).new

      # List of hooks to run before each top-level example group.
      protected getter before_all_hooks = Deque(ExampleGroupHook).new

      # List of hooks to run before every example.
      protected getter before_each_hooks = Deque(ExampleHook).new

      # List of hooks to run after all examples in the test suite.
      protected getter after_suite_hooks = Deque(ExampleGroupHook).new

      # List of hooks to run after each top-level example group.
      protected getter after_all_hooks = Deque(ExampleGroupHook).new

      # List of hooks to run after every example.
      protected getter after_each_hooks = Deque(ExampleHook).new

      # List of hooks to run around every example.
      protected getter around_each_hooks = Deque(ExampleProcsyHook).new

      # Attaches a hook to be invoked before all examples in the test suite.
      def add_before_suite_hook(hook)
        @before_suite_hooks.push(hook)
      end

      # Defines a block of code to execute before all examples in the test suite.
      def before_suite(&block)
        hook = ExampleGroupHook.new(&block)
        add_before_suite_hook(hook)
      end

      # Attaches a hook to be invoked before each top-level example group.
      def add_before_all_hook(hook)
        @before_all_hooks.push(hook)
      end

      # Defines a block of code to execute before each top-level example group.
      def before_all(&block)
        hook = ExampleGroupHook.new(&block)
        add_before_all_hook(hook)
      end

      # Attaches a hook to be invoked before every example.
      # The current example is provided as a block argument.
      def add_before_each_hook(hook)
        @before_each_hooks.push(hook)
      end

      # Defines a block of code to execute before every.
      # The current example is provided as a block argument.
      def before_each(&block : Example -> _)
        hook = ExampleHook.new(&block)
        add_before_each_hook(hook)
      end

      # Attaches a hook to be invoked after all examples in the test suite.
      def add_after_suite_hook(hook)
        @after_suite_hooks.unshift(hook)
      end

      # Defines a block of code to execute after all examples in the test suite.
      def after_suite(&block)
        hook = ExampleGroupHook.new(&block)
        add_after_suite_hook(hook)
      end

      # Attaches a hook to be invoked after each top-level example group.
      def add_after_all_hook(hook)
        @after_all_hooks.unshift(hook)
      end

      # Defines a block of code to execute after each top-level example group.
      def after_all(&block)
        hook = ExampleGroupHook.new(&block)
        add_after_all_hook(hook)
      end

      # Attaches a hook to be invoked after every example.
      # The current example is provided as a block argument.
      def add_after_each_hook(hook)
        @after_each_hooks.unshift(hook)
      end

      # Defines a block of code to execute after every example.
      # The current example is provided as a block argument.
      def after_each(&block : Example -> _)
        hook = ExampleHook.new(&block)
        add_after_each_hook(hook)
      end

      # Attaches a hook to be invoked around every example.
      # The current example in procsy form is provided as a block argument.
      def add_around_each_hook(hook)
        @around_each_hooks.push(hook)
      end

      # Defines a block of code to execute around every example.
      # The current example in procsy form is provided as a block argument.
      def around_each(&block : Example::Procsy -> _)
        hook = ExampleProcsyHook.new(label: "around_each", &block)
        add_around_each_hook(hook)
      end

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
        else            Formatting::BroadcastFormatter.new(formatters)
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
      def add_node_filter(filter : NodeFilter)
        @filters << filter
      end

      # Specifies one or more tags to constrain running examples to.
      def filter_run_including(*tags : Symbol, **values)
        tags.each { |tag| @filters << TagNodeFilter.new(tag.to_s) }
        values.each { |tag, value| @filters << TagNodeFilter.new(tag.to_s, value.to_s) }
      end

      # Adds a filter to prevent examples from running.
      def add_node_reject(filter : NodeFilter)
        @rejects << filter
      end

      # Specifies one or more tags to exclude from running examples.
      def filter_run_excluding(*tags : Symbol, **values)
        tags.each { |tag| @rejects << TagNodeFilter.new(tag.to_s) }
        values.each { |tag, value| @rejects << TagNodeFilter.new(tag.to_s, value.to_s) }
      end

      # Specifies one or more tags to filter on only if they're present in the spec.
      def filter_run_when_matching(*tags : Symbol, **values)
        tags.each { |tag| @match_filters[tag] = nil }
        values.each { |tag, value| @match_filters[tag] = value.to_s }
      end

      # Retrieves a filter that determines which examples can run.
      # If no filters were added with `#add_node_filter`,
      # then the returned filter will allow all examples to be run.
      protected def node_filter
        case (filters = @filters)
        when .empty? then NullNodeFilter.new
        when .one?   then filters.first
        else              CompositeNodeFilter.new(filters)
        end
      end

      # Retrieves a filter that prevents examples from running.
      # If no filters were added with `#add_node_reject`,
      # then the returned filter will allow all examples to be run.
      protected def node_reject
        case (filters = @rejects)
        when .empty? then NullNodeFilter.new(false)
        when .one?   then filters.first
        else              CompositeNodeFilter.new(filters)
        end
      end
    end
  end
end
