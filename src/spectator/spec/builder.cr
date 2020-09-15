require "../example"
require "../example_context_method"
require "../example_group"

module Spectator
  class Spec::Builder
    # Stack tracking the current group.
    # The bottom of the stack (first element) is the root group.
    # The root group should never be removed.
    # The top of the stack (last element) is the current group.
    # New examples should be added to the current group.
    @group_stack : Deque(ExampleGroup)

    def initialize
      root_group = ExampleGroup.new
      @group_stack = Deque(ExampleGroup).new
      @group_stack.push(root_group)
    end

    def add_example
      raise NotImplementedError.new("#add_example")
    end

    def start_group(name, source = nil) : ExampleGroup
      {% if flag?(:spectator_debug) %}
        puts "Start group: #{name.inspect} @ #{source}"
      {% end %}
      ExampleGroup.new(name, source, current_group).tap do |group|
        @group_stack << group
      end
    end

    def end_group
      {% if flag?(:spectator_debug) %}
        puts "End group: #{current_group}"
      {% end %}
      raise "Can't pop root group" if root?

      @group_stack.pop
    end

    def add_example(name, source, context, &block : Example, Context ->)
      {% if flag?(:spectator_debug) %}
        puts "Add example: #{name} @ #{source}"
      {% end %}
      delegate = ExampleContextDelegate.new(context, block)
      Example.new(delegate, name, source, current_group)
      # The example is added to the current group by `Example` initializer.
    end

    def build
      raise NotImplementedError.new("#build")
    end

    # Checks if the current group is the root group.
    private def root?
      @group_stack.size == 1
    end

    # Retrieves the root group.
    private def root_group
      @group_stack.first
    end

    # Retrieves the current group.
    # This is the group that new examples should be added to.
    private def current_group
      @group_stack.last
    end
  end
end
