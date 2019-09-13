require "./root_example_group_builder"
require "./nested_example_group_builder"

module Spectator::Builders
  struct ExampleGroupStack
    getter root

    def initialize
      @root = RootExampleGroupBuilder.new
      @stack = Deque(ExampleGroupBuilder).new(1, @root)
    end

    def current
      @stack.last
    end

    def push(group : NestedExampleGroupBuilder)
      current.add_child(group)
      @stack.push(group)
    end

    def pop
      raise "Attempted to pop root example group from stack" if current == root

      @stack.pop
    end
  end
end
