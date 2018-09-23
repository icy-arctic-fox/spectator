require "./dsl/*"

module Spectator
  module DSL
    macro root(what, &block)
      module SpectatorExamples
        include StructureDSL
        
        describe({{what}}) {{block}}
      end
    end
  end
end
