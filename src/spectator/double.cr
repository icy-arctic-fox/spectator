module Spectator
  abstract class Double
    macro stub(definition)
      delegate {{definition.name.id}}, to: @internal

      private class Internal
        def {{definition.name.id}}({{definition.args.splat}})
          {{definition.block.body}}
        end
      end
    end
  end
end
