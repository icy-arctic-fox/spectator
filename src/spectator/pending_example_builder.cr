require "./example"
require "./location"
require "./metadata"
require "./node_builder"

module Spectator
  # Constructs pending examples.
  # Call `#build` to produce an `Example`.
  class PendingExampleBuilder < NodeBuilder
    # Creates the builder.
    # The *name*, *location*, and *metadata* will be applied to the `Example` produced by `#build`.
    # A default *reason* can be given in case the user didn't provide one.
    def initialize(@name : String? = nil, @location : Location? = nil,
                   @metadata : Metadata? = nil, @reason : String? = nil)
    end

    # Constructs an example with previously defined attributes.
    # The *parent* is an already constructed example group to nest the new example under.
    # It can be nil if the new example won't have a parent.
    def build(parent = nil)
      Example.pending(@name, @location, parent, @metadata, @reason)
    end
  end
end
