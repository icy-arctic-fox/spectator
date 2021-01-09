require "./label"
require "./source"

module Spectator
  # Information about a hook tied to an example group and a proc to invoke it.
  class ExampleGroupHook
    # Location of the hook in source code.
    getter! source : Source

    # User-defined description of the hook.
    getter! label : Label

    @proc : ->

    # Creates the hook with a proc.
    # The *proc* will be called when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(@proc : (->), *, @source : Source? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block will be executed when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(*, @source : Source? = nil, @label : Label = nil, &block : -> _)
      @proc = block
    end

    # Invokes the hook.
    def call : Nil
      @proc.call
    end

    # Produces the string representation of the hook.
    # Includes the source and label if they're not nil.
    def to_s(io)
      io << "example group hook"

      if (label = @label)
        io << ' '
        io << label
      end

      if (source = @source)
        io << " @ "
        io << source
      end
    end
  end
end
