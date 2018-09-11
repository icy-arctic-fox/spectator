require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    CURRENT_CONTEXT = Spectator::ROOT_CONTEXT
    CONTEXT_MODULE = ::Spectator::Examples
    GIVEN_VARIABLES = [] of Object

    module Locals
    end
  end
end
