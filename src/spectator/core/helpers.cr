require "./context"
require "./hooks"

module Spectator::Core
  module Helpers
    def self.uninitialized_value_from_proc(proc : -> T) : T forall T
      # The `uninitialized` keyword can't be used without assigning it to a variable.
      # The compiler produces: `Error: undefined method 'uninitialized' for top-level`.
      # This is a workaround.
      value = uninitialized T
      value
    end
  end

  module HelpersDSL
    macro let(expr)
      %block = -> do
        {{expr.value}}
      end

      {{expr.target}} = %block.call

      before_each do
        {{expr.target}} = %block.call
      end
    end

    macro let?(expr)
      %block = -> do
        {{expr.value}}
      end

      {{expr.target}} = nil.as(typeof(%block.call)?)

      before_each do
        {{expr.target}} = %block.call
      end
    end

    macro let!(expr)
      %block = -> do
        {{expr.value}}
      end

      {{expr.target}} = ::Spectator::Core::Helpers.uninitialized_value_from_proc(%block)

      before_each do
        {{expr.target}} = %block.call
      end
    end
  end

  struct ContextDSL
    include HelpersDSL
  end
end
