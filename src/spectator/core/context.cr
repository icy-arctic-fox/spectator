require "./dsl"
require "./hooks"
require "./memoization"
require "./methods"

module Spectator::Core
  module Context
    include DSL
    include Hooks
    include Memoization
    include Methods
  end
end

Spectator.def_example_alias(:it)
