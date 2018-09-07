require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    CONTEXT_MODULE = ::Spectator::Examples

    module Locals
    end
  end
end
