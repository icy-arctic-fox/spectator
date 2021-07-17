require "./example_group_builder"
require "./example_group_iteration"

module Spectator
  class IterativeExampleGroupBuilder(T) < ExampleGroupBuilder
    def initialize(@collection : Enumerable(T),
      location : Location? = nil, metadata : Metadata = Metadata.new)
      super(nil, location, metadata)
    end

    def build(parent = nil)
      ExampleGroup.new(@name, @location, parent, @metadata).tap do |group|
        @before_all_hooks.each { |hook| group.add_before_all_hook(hook) }
        @before_each_hooks.each { |hook| group.add_before_each_hook(hook) }
        @after_all_hooks.each { |hook| group.add_after_all_hook(hook) }
        @after_each_hooks.each { |hook| group.add_after_each_hook(hook) }
        @around_each_hooks.each { |hook| group.add_around_each_hook(hook) }
        @collection.each do |item|
          ExampleGroupIteration.new(item, item.inspect, @location, group).tap do |iteration|
            @children.each(&.build(iteration))
          end
        end
      end
    end
  end
end
