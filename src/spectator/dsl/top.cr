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
      # Example:
      # ```
      # Spectator.describe Foo do
      #   # Your examples for `Foo` go here.
      # end
      # ```
      # NOTE: Inside the block, the `Spectator` prefix is no longer needed.
      # Actually, prefixing methods and macros with `Spectator`
      # most likely won't work and can cause compiler errors.
      macro {{method.id}}(description, &block)
        class ::SpectatorTestContext
          {{method.id}}(\{{description}}) \{{block}}
        end
      end
    {% end %}
  end
end
