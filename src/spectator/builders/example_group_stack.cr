module Spectator::Builders
  struct ExampleGroupStack
    getter root = RootExampleGroupBuilder.new

    @stack = Deque(ExampleGroupBuilder).new(1, @root)

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
