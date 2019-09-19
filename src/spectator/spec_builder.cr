require "./spec_builder/*"

module Spectator
  # Global builder used to create the runtime instance of the spec.
  # The DSL methods call into this module to generate parts of the spec.
  # Once the DSL is done, the `#build` method can be invoked
  # to create the entire spec as a runtime instance.
  module SpecBuilder
    extend self

    @@stack = ExampleGroupStack.new

    # Begins a new nested group in the spec.
    # A corresponding `#end_group` call must be made
    # when the group being started is finished.
    # See `NestedExampleGroupBuilder#initialize` for the arguments
    # as arguments to this method are passed directly to it.
    def start_group(*args) : Nil
      group = NestedExampleGroupBuilder.new(*args)
      @@stack.push(group)
    end

    # Begins a new sample group in the spec -
    # that is, a group defined by the `StructureDSL#sample` macro in the DSL.
    # A corresponding `#end_group` call must be made
    # when the group being started is finished.
    # See `SampleExampleGroupBuilder#initialize` for the arguments
    # as arguments to this method are passed directly to it.
    def start_sample_group(*args) : Nil
      group = SampleExampleGroupBuilder.new(*args)
      @@stack.push(group)
    end

    # Marks the end of a group in the spec.
    # This must be called for every `#start_group` and `#start_sample_group` call.
    # It is also important to line up the start and end calls.
    # Otherwise examples might get placed into wrong groups.
    def end_group : Nil
      @@stack.pop
    end

    # Adds an example type to the current group.
    # The class name of the example should be passed as an argument.
    # The example will be instantiated later.
    def add_example(description : String, source : Source,
                    example_type : ::SpectatorTest.class, &runner : ::SpectatorTest ->) : Nil
      builder = ->{ example_type.new.as(::SpectatorTest) }
      factory = ExampleBuilder.new(description, source, builder, runner)
      @@stack.current.add_child(factory)
    end

    # Adds a block of code to run before all examples in the current group.
    def add_before_all_hook(&block : ->) : Nil
      @@stack.current.add_before_all_hook(block)
    end

    # Adds a block of code to run before each example in the current group.
    def add_before_each_hook(&block : TestMethod) : Nil
      @@stack.current.add_before_each_hook(block)
    end

    # Adds a block of code to run after all examples in the current group.
    def add_after_all_hook(&block : ->) : Nil
      @@stack.current.add_after_all_hook(block)
    end

    # Adds a block of code to run after each example in the current group.
    def add_after_each_hook(&block : TestMethod) : Nil
      @@stack.current.add_after_each_hook(block)
    end

    # Adds a block of code to run before and after each example in the current group.
    # The block of code will be given another hook as an argument.
    # It is expected that the block will call the hook.
    def add_around_each_hook(&block : ::SpectatorTest, Proc(Nil) ->) : Nil
      @@stack.current.add_around_each_hook(block)
    end

    # Adds a pre-condition to run at the start of every example in the current group.
    def add_pre_condition(&block : ->) : Nil
      @@stack.current.add_pre_condition(block)
    end

    # Adds a post-condition to run at the end of every example in the current group.
    def add_post_condition(&block : ->) : Nil
      @@stack.current.add_post_condition(block)
    end

    # Builds the entire spec and returns it as a test suite.
    # This should be called only once after the entire spec has been defined.
    protected def build(filter : ExampleFilter) : TestSuite
      group = @@stack.root.build
      TestSuite.new(group, filter)
    end
  end
end
