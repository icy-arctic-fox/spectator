require "./hooks"
require "./memoization"

module Spectator
  module Core::Context
    include Hooks
    include Memoization

    abstract def add_child(child : Item)

    def add_example(description = nil, *, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : Example
      location = LocationRange.new(file, line, end_line)
      example = Example.new(description.try &.to_s, location, &block)
      add_child(example)
      example
    end
  end

  macro alias_example_group_to(name)
    module ::Spectator::Core::Context
      def {{name.id}}(description = nil, *, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &)
        location = LocationRange.new(file, line, end_line)
        group = ExampleGroup.new(description.try &.to_s, location)
        add_child(group)
        with group yield group
        group
      end
    end
  end

  alias_example_group_to :context
  alias_example_group_to :describe

  macro alias_example_to(name)
    module ::Spectator::Core::Context
      def {{name.id}}(description = nil, *, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : Example
        location = LocationRange.new(file, line, end_line)
        example = Example.new(description.try &.to_s, location, &block)
        add_child(example)
        example
      end
    end
  end

  alias_example_to :specify
  alias_example_to :it
end
