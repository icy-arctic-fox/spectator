module Spectator::DSL
  module Builder
    extend self

    @@group_stack = Array(ExampleGroupBuilder).new(1, root_group)

    private class_getter root_group = RootExampleGroupBuilder.new

    private def current_group
      @@group_stack.last
    end

    private def push_group(group : NestedExampleGroupBuilder)
      current_group.add_child(group)
      @@group_stack.push(group)
    end

    def start_group(*args) : Nil
      group = NestedExampleGroupBuilder.new(*args)
      push_group(group)
    end

    def start_given_group(*args) : Nil
      group = GivenExampleGroupBuilder.new(*args)
      push_group(group)
    end

    def end_group : Nil
      @@group_stack.pop
    end

    def add_example(example_type : Example.class) : Nil
      factory = ExampleFactory.new(example_type)
      current_group.add_child(factory)
    end

    def add_before_all_hook(&block : ->) : Nil
      current_group.add_before_all_hook(block)
    end

    def add_before_each_hook(&block : ->) : Nil
      current_group.add_before_each_hook(block)
    end

    def add_after_all_hook(&block : ->) : Nil
      current_group.add_after_all_hook(block)
    end

    def add_after_each_hook(&block : ->) : Nil
      current_group.add_after_each_hook(block)
    end

    def add_around_each_hook(&block : Proc(Nil) ->) : Nil
      current_group.add_around_each_hook(block)
    end

    protected def build : ExampleGroup
      root_group.build(Internals::SampleValues.empty)
    end
  end
end
