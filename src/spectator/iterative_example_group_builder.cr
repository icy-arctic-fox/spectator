require "./example_group"
require "./example_group_builder"
require "./example_group_iteration"
require "./location"
require "./metadata"

module Spectator
  # Progressively constructs an iterative example group.
  # Hooks and builders for child nodes can be added over time to this builder.
  # When done, call `#build` to produce an `ExampleGroup` with nested `ExampleGroupIteration` instances.
  class IterativeExampleGroupBuilder(T) < ExampleGroupBuilder
    # Creates the builder.
    # Initially, the builder will have no children and no hooks.
    # The *name*, *location*, and *metadata* will be applied to the `ExampleGroup` produced by `#build`.
    # The *collection* is the set of items to create sub-nodes for.
    # The *iterators* is a list of optional names given to items in the collection.
    def initialize(@collection : Enumerable(T), name : String? = nil, @iterators : Array(String) = [] of String,
                   location : Location? = nil, metadata : Metadata? = nil)
      super(name, location, metadata)
    end

    # Constructs an iterative example group with previously defined attributes, children, and hooks.
    # The *parent* is an already constructed example group to nest the new example group under.
    # It can be nil if the new example group won't have a parent.
    def build(parent = nil)
      ExampleGroup.new(@name, @location, parent, @metadata).tap do |group|
        # Hooks are applied once to the outer group,
        # instead of multiple times for each inner group (iteration).
        apply_hooks(group)

        @collection.each do |item|
          ExampleGroupIteration.new(item, iteration_name(item), @location, group).tap do |iteration|
            @children.each(&.build(iteration))
          end
        end
      end
    end

    # Constructs the name of an example group iteration.
    private def iteration_name(item)
      if item.is_a?(Tuple) && @iterators.size > 1
        item.zip?(@iterators).map do |(subitem, iterator)|
          if iterator
            "#{iterator}: #{subitem.inspect}"
          else
            subitem.inspect
          end
        end.join("; ")
      else
        if iterator = @iterators.first?
          "#{iterator}: #{item.inspect}"
        else
          item.inspect
        end
      end
    end
  end
end
