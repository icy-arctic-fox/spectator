require "./node_builder"

module Spectator
  class PendingExampleBuilder < NodeBuilder
    def initialize(@name : String? = nil, @location : Location? = nil, @metadata : Metadata = Metadata.new)
    end

    def build(parent)
      Example.pending(@name, @location, parent, @metadata)
    end
  end
end
