module Spectator
  abstract class NodeBuilder
    # Produces a node for a spec.
    abstract def build(parent = nil)
  end
end
