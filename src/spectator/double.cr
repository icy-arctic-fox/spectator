module Spectator
  abstract class Double
    macro stub(definition)
      def {{definition.name.id}}
        @internal.{{definition.name.id}}
      end

      private class Internal
        def {{definition.name.id}}
          {{definition.block.body}}
        end
      end
    end
  end
end
