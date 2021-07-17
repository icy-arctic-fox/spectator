require "./node_builder"

module Spectator
  class ExampleBuilder < NodeBuilder
    def initialize(@context_builder : -> Context, @entrypoint : Example ->,
                   @name : String? = nil, @location : Location? = nil, @metadata : Metadata = Metadata.new)
    end

    def build(parent)
      context = @context_builder.call
      Example.new(context, @entrypoint, @name, @location, parent, @metadata)
    end
  end
end
