require "./helpers"
require "./hooks"
require "./sandbox"
require "./tags"

module Spectator
  module Core::Context
    include Helpers
    include Hooks

    abstract def add_child(child : Item)
  end

  macro alias_example_group_to(name, *tags, **tagged_values)
    module ::Spectator
      module Core::Context
        def {{name.id}}(description = nil, *tags,
                        source_file = __FILE__,
                        source_line = __LINE__,
                        source_end_line = __END_LINE__,
                        **tagged_values, &)
          location = LocationRange.new(source_file, source_line, source_end_line)
          group = ExampleGroup.new(
            description: description.try &.to_s,
            tags: Taggable.create_and_merge_tags(
              tags, tagged_values, {{tags.splat(", ")}} {{tagged_values.double_splat}}),
            location: location,
          )
          add_child(group)
          with group yield group
          group
        end
      end

      def self.{{name.id}}(description = nil, *tags,
                           source_file = __FILE__,
                           source_line = __LINE__,
                           source_end_line = __END_LINE__,
                           **tagged_values, &)
        sandbox.root_example_group.{{name.id}}(description,
          *tags, **tagged_values,
          source_file: source_file,
          source_line: source_line,
          source_end_line: source_end_line) do |group|
          with group yield group
        end
      end
    end
  end

  alias_example_group_to :context
  alias_example_group_to :describe

  macro alias_example_to(name, *tags, **tagged_values)
    module ::Spectator::Core::Context
      def {{name.id}}(description = nil, *tags,
                      source_file = __FILE__,
                      source_line = __LINE__,
                      source_end_line = __END_LINE__,
                      **tagged_values,
                      &block : Example ->) : Example
        location = LocationRange.new(source_file, source_line, source_end_line)
        example = Example.new(
          description: description.try &.to_s,
          tags: Taggable.create_and_merge_tags(
            tags, tagged_values, {{tags.splat(", ")}} {{tagged_values.double_splat}}),
          location: location,
          &block)
        add_child(example)
        example
      end
    end
  end

  alias_example_to :specify
  alias_example_to :it
end
