require "../spec/builder"

module Spectator::DSL
  # Incrementally builds up a test spec from the DSL.
  # This is intended to be used only by the Spectator DSL.
  module Builder
    extend self

    # Underlying spec builder.
    @@builder = Spec::Builder.new

    # Defines a new example group and pushes it onto the group stack.
    # Examples and groups defined after calling this method will be nested under the new group.
    # The group will be finished and popped off the stack when `#end_example` is called.
    #
    # See `Spec::Builder#start_group` for usage details.
    def start_group(*args)
      @@builder.start_group(*args)
    end

    # Completes a previously defined example group and pops it off the group stack.
    # Be sure to call `#start_group` and `#end_group` symmetically.
    #
    # See `Spec::Builder#end_group` for usage details.
    def end_group(*args)
      @@builder.end_group(*args)
    end

    # Defines a new example.
    # The example is added to the group currently on the top of the stack.
    #
    # See `Spec::Builder#add_example` for usage details.
    def add_example(*args, &block : Example, Context ->)
      @@builder.add_example(*args, &block)
    end
  end
end
