module Spectator::Internals
  # Abstract base class for all example hooks.
  # This provides an untyped base for every generic type of `ExampleHooks`.
  #
  # A hook is defined as a `Proc` instance.
  # This class stores any number of hooks for before, after, and "around" an example.
  # The before and after hooks run before and after an example (obviously).
  # These hooks are passed the `Example` instance of the example being run.
  #
  # The around hook is special, in that it does both.
  # It is started before the example runs and finishes after the example has ran.
  # This is suited for methods that use block syntax to wrap some action.
  # For instance: `File#open`.
  # A `Proc` instance is given to each around hook,
  # and the hook is expected to call that proc.
  # If it doesn't then the example won't run, among other things.
  abstract class BaseExampleHooks
    # Creates a new set of hooks for examples.
    # An array of `Proc` instances for each type of hook must be specified.
    def initialize(@before = [] of Example ->, @after = [] of Example ->, @around = [] of Example ->)
    end

    # Runs all of the before hooks.
    # The `example` argument should be the example about to be run.
    abstract def run_before(example : Example)

    # Runs all of the after hooks.
    # The `example` argument should be the example that just ran.
    abstract def run_after(example : Example)

    # Creates a `Proc` that invokes all of the around hooks and a block of code.
    # Invoking the returned proc will call each around hook
    # and finally the block of code provided to this method.
    def wrap_around(&block : ->)
      # If there's no around hooks,
      # the returned proc will just be the block.
      wrapper = block

      # Must wrap in reverse order,
      # so that the first hooks are the outermost and run first.
      @around.reverse_each do |hook|
        wrapper = wrap_proc(hook, wrapper)
      end

      wrapper
    end

    # Utility method for wrapping one proc with another.
    private def wrap_proc(inner : Proc(Nil) ->, wrapper : ->)
      ->{ inner.call(wrapper) }
    end
  end
end
