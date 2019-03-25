module Spectator::DSL
  # Global builder used to create the runtime instance of the spec.
  # The DSL methods call into this module to generate parts of the spec.
  # Once the DSL is done, the `#build` method can be invoked
  # to create the entire spec as a runtime instance.
  module Builder
    extend self

    # Root group that contains all examples and groups in the spec.
    private class_getter root_group = RootExampleGroupBuilder.new

    # Stack for tracking the current group the spec is working in.
    # The last item (top of the stack) is the current group.
    # The first item (bottom of the stack) is the root group (`#root_group`).
    # The root group should never be popped.
    @@group_stack = Array(ExampleGroupBuilder).new(1, root_group)

    # Retrieves the current group the spec is working in.
    private def current_group
      @@group_stack.last
    end

    # Adds a new group to the stack.
    # Calling this method indicates the spec has entered a nested group.
    private def push_group(group : NestedExampleGroupBuilder)
      current_group.add_child(group)
      @@group_stack.push(group)
    end

    # Begins a new nested group in the spec.
    # A corresponding `#end_group` call must be made
    # when the group being started is finished.
    # See `NestedExampleGroupBuilder#initialize` for the arguments
    # as arguments to this method are passed directly to it.
    def start_group(*args) : Nil
      group = NestedExampleGroupBuilder.new(*args)
      push_group(group)
    end

    # Begins a new sample group in the spec -
    # that is, a group defined by the `StructureDSL#sample` macro in the DSL.
    # A corresponding `#end_group` call must be made
    # when the group being started is finished.
    # See `SampleExampleGroupBuilder#initialize` for the arguments
    # as arguments to this method are passed directly to it.
    def start_sample_group(*args) : Nil
      group = SampleExampleGroupBuilder.new(*args)
      push_group(group)
    end

    # Marks the end of a group in the spec.
    # This must be called for every `#start_group` and `#start_sample_group` call.
    # It is also important to line up the start and end calls.
    # Otherwise examples might get placed into wrong groups.
    def end_group : Nil
      @@group_stack.pop
    end

    # Adds an example type to the current group.
    # The class name of the example should be passed as an argument.
    # The example will be instantiated later.
    def add_example(example_type : Example.class) : Nil
      factory = ExampleFactory.new(example_type)
      current_group.add_child(factory)
    end

    # Adds a block of code to run before all examples in the current group.
    def add_before_all_hook(&block : ->) : Nil
      current_group.add_before_all_hook(block)
    end

    # Adds a block of code to run before each example in the current group.
    def add_before_each_hook(&block : ->) : Nil
      current_group.add_before_each_hook(block)
    end

    # Adds a block of code to run after all examples in the current group.
    def add_after_all_hook(&block : ->) : Nil
      current_group.add_after_all_hook(block)
    end

    # Adds a block of code to run after each example in the current group.
    def add_after_each_hook(&block : ->) : Nil
      current_group.add_after_each_hook(block)
    end

    # Adds a block of code to run before and after each example in the current group.
    # The block of code will be given another proc as an argument.
    # It is expected that the block will call the proc.
    def add_around_each_hook(&block : Proc(Nil) ->) : Nil
      current_group.add_around_each_hook(block)
    end

    # Adds a pre-condition to run at the start of every example in the current group.
    def add_pre_condition(&block : ->) : Nil
      current_group.add_pre_condition(block)
    end

    # Adds a post-condition to run at the end of every example in the current group.
    def add_post_condition(&block : ->) : Nil
      current_group.add_post_condition(block)
    end

    # Builds the entire spec and returns it as a test suite.
    # This should be called only once after the entire spec has been defined.
    protected def build(filter : ExampleFilter) : TestSuite
      group = root_group.build(Internals::SampleValues.empty)
      TestSuite.new(group, filter)
    end
  end
end
