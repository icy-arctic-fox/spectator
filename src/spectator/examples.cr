require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    CURRENT_CONTEXT = ::Spectator::Context::ROOT
    CONTEXT_MODULE = ::Spectator::Examples
    GIVEN_VARIABLES = [] of Object

    module Locals
    end
  end
end
