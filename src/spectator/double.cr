module Spectator
  abstract struct Double
    macro stub(definition)
      def {{definition.name.id}}
        {{definition.block.body}}
      end
    end
  end
end
