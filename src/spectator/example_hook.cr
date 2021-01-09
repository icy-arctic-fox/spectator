require "./example_context_delegate"
require "./label"
require "./source"

module Spectator
  # Information about a hook tied to an example and a delegate to invoke it.
  class ExampleHook
    # Location of the hook in source code.
    getter! source : Source

    # User-defined description of the hook.
    getter! label : Label

    # Creates the hook with an example context delegate.
    # The *delegate* will be called when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(@delegate : ExampleContextDelegate, *, @source : Source? = nil, @label : Label = nil)
    end

    # Creates the hook with a block.
    # The block must take a single argument - the current example.
    # The block will be executed when the hook is invoked.
    # A *source* and *label* can be provided for debugging.
    def initialize(*, @source : Source? = nil, @label : Label = nil, &block : Example -> _)
      @delegate = ExampleContextDelegate.null(&block)
    end

    # Invokes the hook.
    # The *example* refers to the current example.
    def call(example : Example) : Nil
      @delegate.call(example)
    end
  end
end
