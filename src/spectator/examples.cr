require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    PARENT_LOCALS_MODULE = ::Spectator::Examples

    module Locals
    end
  end
end
