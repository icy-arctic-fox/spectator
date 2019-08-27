module Spectator
  module Double
    macro stub(definition)
      def {{definition.name.id}}
        {{definition.block.body}}
      end
    end
  end
end
