require "./config/*"
require "./node_filter"
require "./example_group"
require "./filtered_example_iterator"
require "./formatting/formatter"
require "./node_iterator"
require "./run_flags"

module Spectator
  # Provides customization and describes specifics for how Spectator will run and report tests.
  class Config
    # Primary formatter all events will be sent to.
    getter formatter : Formatting::Formatter

    # Flags indicating how the spec should run.
    getter run_flags : RunFlags

    # Seed used for random number generation.
    getter random_seed : UInt64

    # Filter used to select which examples to run.
    getter node_filter : NodeFilter

    # Filter used to select which examples to _not_ run.
    getter node_reject : NodeFilter

    # Tags to filter on if they're present in a spec.
    protected getter match_filters : Metadata

    # List of hooks to run before all examples in the test suite.
    protected getter before_suite_hooks : Deque(ExampleGroupHook)

    # List of hooks to run before each top-level example group.
    protected getter before_all_hooks : Deque(ExampleGroupHook)

    # List of hooks to run before every example.
    protected getter before_each_hooks : Deque(ExampleHook)

    # List of hooks to run after all examples in the test suite.
    protected getter after_suite_hooks : Deque(ExampleGroupHook)

    # List of hooks to run after each top-level example group.
    protected getter after_all_hooks : Deque(ExampleGroupHook)

    # List of hooks to run after every example.
    protected getter after_each_hooks : Deque(ExampleHook)

    # List of hooks to run around every example.
    protected getter around_each_hooks : Deque(ExampleProcsyHook)

    # Creates a new configuration.
    # Properties are pulled from *source*.
    # Typically, *source* is a `Config::Builder`.
    def initialize(source)
      @formatter = source.formatter
      @run_flags = source.run_flags
      @random_seed = source.random_seed
      @node_filter = source.node_filter
      @node_reject = source.node_reject
      @match_filters = source.match_filters

      @before_suite_hooks = source.before_suite_hooks
      @before_all_hooks = source.before_all_hooks
      @before_each_hooks = source.before_each_hooks
      @after_suite_hooks = source.after_suite_hooks
      @after_all_hooks = source.after_all_hooks
      @after_each_hooks = source.after_each_hooks
      @around_each_hooks = source.around_each_hooks
    end

    # Produces the default configuration.
    def self.default : self
      Builder.new.build
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

    # Creates an iterator configured to select the filtered examples.
    def iterator(group : ExampleGroup)
      match_filter = match_filter(group)
      iterator = FilteredExampleIterator.new(group, @node_filter)
      iterator = iterator.select(match_filter) if match_filter
      iterator.reject(@node_reject)
    end

    # Creates a node filter if any conditionally matching filters apply to an example group.
    private def match_filter(group : ExampleGroup) : NodeFilter?
      iterator = NodeIterator.new(group)
      filters = @match_filters.compact_map do |key, value|
        filter = TagNodeFilter.new(key.to_s, value)
        filter.as(NodeFilter) if iterator.rewind.any?(filter)
      end
      CompositeNodeFilter.new(filters) unless filters.empty?
    end

    # Retrieves the configured random number generator.
    # This will produce the same generator with the same seed every time.
    def random
      Random.new(random_seed)
    end
  end
end
