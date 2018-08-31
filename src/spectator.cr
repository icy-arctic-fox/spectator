require "./spectator/*"

# TODO: Write documentation for `Spectator`
module Spectator
  VERSION = "0.1.0"

  ALL_EXAMPLES = [] of Example

  macro describe(what, source_file = __FILE__, source_line = __LINE__, &block)
    module Spectator
      module Examples
        DSL.describe({{what}}) {{block}}
      end
    end
    {% debug %}
  end

  at_exit do
    Runner.new(ALL_EXAMPLES).run
  end
end
