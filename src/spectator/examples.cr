require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    CONTEXT_MODULE = ::Spectator::Examples
    GIVEN_VARIABLES = [] of Object

    module Locals
    end
  end
end
