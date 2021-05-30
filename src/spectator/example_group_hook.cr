require "./label"
require "./location"

module Spectator
  # Information about a hook tied to an example group and a proc to invoke it.
  class ExampleGroupHook
    # Location of the hook in source code.
    getter! location : Location

    # User-defined description of the hook.
    getter! label : Label

    @proc : ->

    # Creates the hook with a proc.
    # The *proc* will be called when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(@proc : (->), *, @location : Location? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block will be executed when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(*, @location : Location? = nil, @label : Label = nil, &block : -> _)
      @proc = block
    end

    # Invokes the hook.
    def call : Nil
      @proc.call
    end

    # Produces the string representation of the hook.
    # Includes the location and label if they're not nil.
    def to_s(io)
      io << "example group hook"

      if (label = @label)
        io << ' ' << label
      end

      if (location = @location)
        io << " @ " << location
      end
    end
  end
end
