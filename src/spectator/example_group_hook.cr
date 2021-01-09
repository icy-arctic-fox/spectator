require "./context_delegate"
require "./label"
require "./source"

module Spectator
  # Information about a hook tied to an example group and a delegate to invoke it.
  class ExampleGroupHook
    # Location of the hook in source code.
    getter! source : Source

    # User-defined description of the hook.
    getter! label : Label

    # Creates the hook with a context delegate.
    # The *delegate* will be called when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(@delegate : ContextDelegate, *, @source : Source? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block will be executed when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(*, @source : Source? = nil, @label : Label = nil, &block : -> _)
      @delegate = ContextDelegate.null(&block)
    end

    # Invokes the hook.
    def call : Nil
      @delegate.call
    end
  end
end
