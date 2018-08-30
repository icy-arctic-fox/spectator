require "./spectator/*"

# TODO: Write documentation for `Spectator`
module Spectator
  VERSION = "0.1.0"

  macro describe(what, source_file = __FILE__, source_line = __LINE__, &block)
    module Spectator
      module Examples
        DSL.describe({{what}}) {{block}}
      end
    end
    {% debug %}
  end

  macro _spec_add_example(example)
    {{example.id}}.run
  end

  at_exit do
    # TODO
  end
end
