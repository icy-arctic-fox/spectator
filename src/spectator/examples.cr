require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    PARENT_CONTEXT_NAME = ::Spectator::Examples

    module Context
    end
  end
end
