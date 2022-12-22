require "./context"
require "./example"
require "./location"
require "./metadata"
require "./node_builder"

module Spectator
  # Constructs examples.
  # Call `#build` to produce an `Example`.
  class ExampleBuilder < NodeBuilder
    @name : Proc(Example, String) | String?

    # Creates the builder.
    # A proc provided by *context_builder* is used to create a unique `Context` for each example produced by `#build`.
    # The *entrypoint* indicates the proc used to invoke the test code in the example.
    # The *name*, *location*, and *metadata* will be applied to the `Example` produced by `#build`.
    def initialize(@context_builder : -> Context, @entrypoint : Example ->,
                   @name : String? = nil, @location : Location? = nil, @metadata : Metadata? = nil)
    end

    # Creates the builder.
    # A proc provided by *context_builder* is used to create a unique `Context` for each example produced by `#build`.
    # The *entrypoint* indicates the proc used to invoke the test code in the example.
    # The *name* is an interpolated string that runs in the context of the example.
    # *location*, and *metadata* will be applied to the `Example` produced by `#build`.
    def initialize(@context_builder : -> Context, @entrypoint : Example ->,
                   @name : Example -> String, @location : Location? = nil, @metadata : Metadata? = nil)
    end

    # Constructs an example with previously defined attributes and context.
    # The *parent* is an already constructed example group to nest the new example under.
    # It can be nil if the new example won't have a parent.
    def build(parent = nil)
      context = @context_builder.call
      Example.new(context, @entrypoint, @name, @location, parent, @metadata)
    end
  end
end
