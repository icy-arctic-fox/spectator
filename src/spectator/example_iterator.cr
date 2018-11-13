module Spectator
  class ExampleIterator
    include Iterator(Example)

    @stack : Array(Iterator(ExampleComponent))

    def initialize(@group : Iterable(ExampleComponent))
      iter = @group.each.as(Iterator(ExampleComponent))
      @stack = [iter]
    end

    def next
      until @stack.empty?
        item = advance
        return item if item.is_a?(Example)
      end
      stop
    end

    def rewind
      iter = @group.each.as(Iterator(ExampleComponent))
      @stack = [iter]
      self
    end

    private def top
      @stack.last
    end

    private def advance
      item = top.next
      case (item)
      when ExampleGroup
        @stack.push(item.each)
      when Iterator::Stop
        @stack.pop
      else
        item
      end
    end
  end
end
