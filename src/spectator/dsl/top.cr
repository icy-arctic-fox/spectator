require "./groups"

module Spectator::DSL
  module Top
    {% for method in %i[example_group describe context] %}
      # Top-level describe method.
      # All specs in a file must be wrapped in this call.
      # This takes an argument and a block.
      # The argument is what your spec is describing.
      # It can be any Crystal expression,
      # but is typically a class name or feature string.
      # The block should contain all of the examples for what is being described.
      #
      # Example:
      # ```
      # Spectator.describe Foo do
      #   # Your examples for `Foo` go here.
      # end
      # ```
      #
      # Tags can be specified by adding symbols (keywords) after the first argument.
      # Key-value pairs can also be specified.
      #
      # NOTE: Inside the block, the `Spectator` prefix _should not_ be used.
      macro {{method.id}}(description, *tags, **metadata, &block)
        class ::SpectatorTestContext
          {{method.id}}(\{{description}}, \{{tags.splat(", ")}} \{{metadata.double_splat}}) \{{block}}
        end
      end
    {% end %}
  end
end
