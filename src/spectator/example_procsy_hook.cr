require "./label"
require "./location"

module Spectator
  # Information about a hook tied to an example and a proc to invoke it.
  class ExampleProcsyHook
    # Location of the hook in source code.
    getter! location : Location

    # User-defined description of the hook.
    getter! label : Label

    @proc : Example::Procsy ->

    # Creates the hook with a proc.
    # The *proc* will be called when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(@proc : (Example::Procsy ->), *, @location : Location? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block must take a single argument - the current example wrapped in a procsy.
    # The block will be executed when the hook is invoked.
    # A *location* and *label* can be provided for debugging.
    def initialize(*, @location : Location? = nil, @label : Label = nil, &block : Example::Procsy -> _)
      @proc = block
    end

    # Invokes the hook.
    # The *example* refers to the current example.
    def call(procsy : Example::Procsy) : Nil
      @proc.call(procsy)
    end

    # Creates an example procsy that invokes this hook.
    def wrap(procsy : Example::Procsy) : Example::Procsy
      procsy.wrap { call(procsy) }
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
