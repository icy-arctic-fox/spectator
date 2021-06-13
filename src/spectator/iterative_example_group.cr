require "./example_group"
require "./node"

module Spectator
  # Collection of examples and sub-groups executed multiple times.
  # Each sub-node is executed once for each item in a given collection.
  class IterativeExampleGroup(T) < ExampleGroup
    # Creates the iterative example group.
    # The *collection* is a list of items to iterative over each sub-node over.
    # The *location* tracks where the group exists in source code.
    # This group will be assigned to the parent *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    def initialize(collection : Enumerable(T), location : Location? = nil,
                   group : ExampleGroup? = nil, metadata : Metadata = Metadata.new)
      super()

      @nodes = collection.map do |item|
        Iteration.new(item, location, group, metadata).as(Node)
      end
    end

    # Adds the specified *node* to the group.
    # Assigns the node to this group.
    # If the node already belongs to a group,
    # it will be removed from the previous group before adding it to this group.
    def <<(node : Node)
      @nodes.each { |child| child.as(Iteration(T)) << node.dup }
    end

    private class Iteration(T) < ExampleGroup
      def initialize(@item : T, location : Location? = nil,
                     group : ExampleGroup? = nil, metadata : Metadata = Metadata.new)
        super(@item.inspect, location, group, metadata)
      end
    end
  end
end
