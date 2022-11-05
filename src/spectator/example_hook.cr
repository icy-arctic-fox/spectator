require "./label"
require "./location"

module Spectator
  # Information about a hook tied to an example and a proc to invoke it.
  class ExampleHook
    # Method signature for example hooks.
    alias Proc = Example ->

    # Location of the hook in source code.
    getter! location : Location

    # User-defined description of the hook.
    getter! label : Label

    @proc : Proc

    # Creates the hook with a proc.
    # The *proc* will be called when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(@proc : Proc, *, @location : Location? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block must take a single argument - the current example.
    # The block will be executed when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(*, @location : Location? = nil, @label : Label = nil, &block : Proc)
      @proc = block
    end

    # Invokes the hook.
    # The *example* refers to the current example.
    def call(example : Example) : Nil
      @proc.call(example)
    end

    # Produces the string representation of the hook.
    # Includes the location and label if they're not nil.
    def to_s(io : IO) : Nil
      io << "example hook"

      if (label = @label)
        io << ' ' << label
      end

      if (location = @location)
        io << " @ " << location
      end
    end
  end
end
